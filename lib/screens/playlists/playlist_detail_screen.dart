import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song.dart';
import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../state/playlist_state.dart';
import '../../widgets/song_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlistState = context.watch<PlaylistState>();
    final library = context.watch<LibraryState>();
    final playlist = playlistState.playlists.firstWhere((p) => p.id == playlistId);
    final isFavorites = playlistId == favoritesPlaylistId;
    final songs = library.byPaths(playlist.songPaths);
    final playerState = context.read<PlayerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          if (!isFavorites)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'rename') {
                  await _renamePlaylist(context, playlist.id, playlist.name);
                } else if (value == 'delete') {
                  await playlistState.deletePlaylist(playlist.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'delete', child: Text('Delete playlist')),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddToPlaylistFallback(context, playlist.id),
        child: const Icon(Icons.add),
      ),
      body: songs.isEmpty
          ? const Center(child: Text('No songs yet. Tap + to add some.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('${songs.length} songs')),
                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        onPressed: () => playerState.playQueue(songs, sourceLabel: playlist.name),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                        onPressed: () =>
                            playerState.playQueue(songs, sourceLabel: playlist.name, shuffle: true),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: songs.length,
                    onReorder: (oldIndex, newIndex) =>
                        playlistState.reorder(playlist.id, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Dismissible(
                        key: ValueKey(song.data),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete),
                        ),
                        onDismissed: (_) => playlistState.removeSongAt(playlist.id, index),
                        child: SongTile(
                          song: song,
                          onTap: () => playerState.playQueue(songs, startIndex: index, sourceLabel: playlist.name),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _renamePlaylist(BuildContext context, String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      await context.read<PlaylistState>().renamePlaylist(id, newName);
    }
  }
}

/// The FAB on a playlist detail screen adds songs from the whole library
/// (reuses the same picker sheet other screens use to add to a playlist).
void showAddToPlaylistFallback(BuildContext context, String playlistId) {
  final library = context.read<LibraryState>();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _AddSongsPicker(playlistId: playlistId, allSongs: library.sortedSongs),
  );
}

class _AddSongsPicker extends StatefulWidget {
  final String playlistId;
  final List<Song> allSongs;
  const _AddSongsPicker({required this.playlistId, required this.allSongs});

  @override
  State<_AddSongsPicker> createState() => _AddSongsPickerState();
}

class _AddSongsPickerState extends State<_AddSongsPicker> {
  final Set<String> _selected = {};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final songs = _query.trim().isEmpty
        ? widget.allSongs
        : widget.allSongs
            .where((s) => s.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search songs'),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return CheckboxListTile(
                    value: _selected.contains(song.data),
                    title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(song.data);
                      } else {
                        _selected.remove(song.data);
                      }
                    }),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        final library = context.read<LibraryState>();
                        final chosen = library.byPaths(_selected.toList());
                        await context.read<PlaylistState>().addSongsToPlaylist(widget.playlistId, chosen);
                        if (context.mounted) Navigator.pop(context);
                      },
                child: Text('Add ${_selected.length} song(s)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
