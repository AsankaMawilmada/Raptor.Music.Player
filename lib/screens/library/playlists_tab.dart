import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../state/playlist_state.dart';
import '../playlists/playlist_detail_screen.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistState = context.watch<PlaylistState>();
    final playlists = playlistState.playlists;

    if (playlists.isEmpty) {
      return const Center(child: Text('No playlists yet. Tap "New playlist" to create one.'));
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final Playlist playlist = playlists[index];
        final isFavorites = playlist.id == favoritesPlaylistId;
        return ListTile(
          leading: CircleAvatar(
            child: Icon(isFavorites ? Icons.favorite : Icons.queue_music),
          ),
          title: Text(playlist.name),
          subtitle: Text('${playlist.songPaths.length} songs'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: playlist.id)),
          ),
        );
      },
    );
  }
}
