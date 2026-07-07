import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../widgets/artwork.dart';
import '../../widgets/song_tile.dart';
import '../playlists/add_to_playlist_sheet.dart';

class AlbumDetailScreen extends StatelessWidget {
  final int albumId;
  final String albumName;
  const AlbumDetailScreen({super.key, required this.albumId, required this.albumName});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final songs = library.songsForAlbum(albumId);
    final playerState = context.read<PlayerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(albumName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Add all to playlist',
            onPressed: () => showAddToPlaylistSheet(context, songs),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Artwork(id: albumId, type: ArtworkType.ALBUM, size: 96, radius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(albumName, style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('${songs.length} songs'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                            onPressed: () => playerState.playQueue(songs, sourceLabel: albumName),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle'),
                            onPressed: () => playerState.playQueue(songs, sourceLabel: albumName, shuffle: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (var i = 0; i < songs.length; i++)
            SongTile(
              song: songs[i],
              showAlbum: false,
              onTap: () => playerState.playQueue(songs, startIndex: i, sourceLabel: albumName),
            ),
        ],
      ),
    );
  }
}
