import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../widgets/song_tile.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final songs = library.filteredSongs;
    final playerState = context.read<PlayerState>();

    if (songs.isEmpty) {
      return const Center(child: Text('No songs found on this device.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<LibraryState>().rescan(),
      child: ListView.builder(
        itemCount: songs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${songs.length} songs', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle play'),
                    onPressed: () => playerState.playQueue(songs, sourceLabel: 'All songs', shuffle: true),
                  ),
                ],
              ),
            );
          }
          final song = songs[index - 1];
          return SongTile(
            song: song,
            onTap: () => playerState.playQueue(songs, startIndex: index - 1, sourceLabel: 'All songs'),
          );
        },
      ),
    );
  }
}
