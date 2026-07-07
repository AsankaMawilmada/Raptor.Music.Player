import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../widgets/song_tile.dart';
import '../playlists/add_to_playlist_sheet.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderPath;
  const FolderDetailScreen({super.key, required this.folderPath});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final folder = library.folders.firstWhere((f) => f.path == folderPath);
    final playerState = context.read<PlayerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Add folder to playlist',
            onPressed: () => showAddToPlaylistSheet(context, folder.songs),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(folder.path,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Shuffle'),
                  onPressed: () => playerState.playQueue(folder.songs, sourceLabel: folder.name, shuffle: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: folder.songs.length,
              itemBuilder: (context, index) => SongTile(
                song: folder.songs[index],
                onTap: () => playerState.playQueue(folder.songs, startIndex: index, sourceLabel: folder.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
