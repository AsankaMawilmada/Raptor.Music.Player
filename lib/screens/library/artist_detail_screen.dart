import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../widgets/song_tile.dart';
import '../playlists/add_to_playlist_sheet.dart';

class ArtistDetailScreen extends StatelessWidget {
  final int artistId;
  final String artistName;
  const ArtistDetailScreen({super.key, required this.artistId, required this.artistName});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final songs = library.songsForArtist(artistId);
    final playerState = context.read<PlayerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(artistName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Add all to playlist',
            onPressed: () => showAddToPlaylistSheet(context, songs),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () => playerState.playQueue(songs, sourceLabel: artistName, shuffle: true),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) => SongTile(
          song: songs[index],
          onTap: () => playerState.playQueue(songs, startIndex: index, sourceLabel: artistName),
        ),
      ),
    );
  }
}
