import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song.dart';
import '../../state/playlist_state.dart';

/// Bottom sheet used everywhere a user can add one or more songs (a single
/// track, a whole album, an artist's catalog, or an entire folder) to a
/// playlist. Playlists have no song-count limit, so this always succeeds.
void showAddToPlaylistSheet(BuildContext context, List<Song> songs) {
  final playlistState = context.read<PlaylistState>();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text('Add ${songs.length} song${songs.length == 1 ? '' : 's'} to playlist',
                        style: Theme.of(sheetContext).textTheme.titleMedium),
                  ],
                ),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.add)),
                title: const Text('New playlist'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _promptCreatePlaylist(context, songs);
                },
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlistState.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistState.playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(playlist.name),
                      subtitle: Text('${playlist.songPaths.length} songs'),
                      onTap: () async {
                        await playlistState.addSongsToPlaylist(playlist.id, songs);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to ${playlist.name}')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _promptCreatePlaylist(BuildContext context, List<Song> songs) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('New playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Playlist name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    ),
  );
  if (name == null || name.isEmpty || !context.mounted) return;
  final playlistState = context.read<PlaylistState>();
  final playlist = await playlistState.createPlaylist(name, songs: songs);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created "${playlist.name}" with ${songs.length} song(s)')),
    );
  }
}
