import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song.dart';
import '../../services/library_service.dart';
import '../../state/library_state.dart';
import '../../state/playlist_state.dart';

/// Builds a new playlist from either whole folders (every track inside is
/// added) or individually picked tracks - either source can contribute any
/// number of songs, there is no cap.
class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedFolderPaths = {};
  final Set<String> _selectedSongPaths = {};
  String _query = '';
  int _mode = 0; // 0 = folders, 1 = songs

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final folders = library.folders;
    final songs = _query.trim().isEmpty
        ? library.sortedSongs
        : library.sortedSongs
            .where((s) =>
                s.title.toLowerCase().contains(_query.toLowerCase()) ||
                s.artist.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    final selectedCount = _selectedFolderPaths.fold<int>(
          0,
          (sum, path) => sum + (folders.firstWhere((f) => f.path == path).songs.length),
        ) +
        _selectedSongPaths.length;

    return Scaffold(
      appBar: AppBar(title: const Text('New playlist')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('From folders'), icon: Icon(Icons.folder)),
                ButtonSegment(value: 1, label: Text('From songs'), icon: Icon(Icons.music_note)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _mode == 0
                ? ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final selected = _selectedFolderPaths.contains(folder.path);
                      return CheckboxListTile(
                        value: selected,
                        title: Text(folder.name),
                        subtitle: Text('${folder.songs.length} songs • ${folder.path}',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        secondary: const Icon(Icons.folder),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedFolderPaths.add(folder.path);
                            } else {
                              _selectedFolderPaths.remove(folder.path);
                            }
                          });
                        },
                      );
                    },
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search songs',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            final selected = _selectedSongPaths.contains(song.data);
                            return CheckboxListTile(
                              value: selected,
                              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedSongPaths.add(song.data);
                                  } else {
                                    _selectedSongPaths.remove(song.data);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: selectedCount == 0 || _nameController.text.trim().isEmpty
                    ? null
                    : () => _create(context, folders),
                child: Text('Create playlist ($selectedCount song${selectedCount == 1 ? '' : 's'})'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, List<MusicFolder> folders) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final Set<Song> combined = {};
    for (final path in _selectedFolderPaths) {
      final folder = folders.firstWhere((f) => f.path == path);
      combined.addAll(folder.songs);
    }
    final library = context.read<LibraryState>();
    combined.addAll(library.byPaths(_selectedSongPaths.toList()));

    final playlistState = context.read<PlaylistState>();
    final playlist = await playlistState.createPlaylist(name, songs: combined);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created "${playlist.name}" with ${combined.length} song(s)')),
      );
    }
  }
}
