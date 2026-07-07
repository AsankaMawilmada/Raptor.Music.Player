import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../screens/playlists/add_to_playlist_sheet.dart';
import '../state/player_state.dart';
import '../state/playlist_state.dart';
import 'artwork.dart';

String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  final hours = d.inHours;
  final mm = hours > 0 ? minutes.toString().padLeft(2, '0') : minutes.toString();
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool showAlbum;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showAlbum = true,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final isCurrent = playerState.currentSong?.data == song.data;
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Artwork(id: song.albumId, type: ArtworkType.ALBUM, size: 48),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? scheme.primary : null,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        showAlbum ? '${song.artist} • ${song.album}' : song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => showSongActionsSheet(context, song),
      ),
    );
  }
}

void showSongActionsSheet(BuildContext context, Song song) {
  final playerState = context.read<PlayerState>();
  final playlistState = context.read<PlaylistState>();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final isFav = playlistState.isFavorite(song);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Artwork(id: song.albumId, type: ArtworkType.ALBUM, size: 40),
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: const Text('Play next'),
              onTap: () {
                playerState.playNext(song);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add to queue'),
              onTap: () {
                playerState.addToQueue(song);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              title: Text(isFav ? 'Remove from favorites' : 'Add to favorites'),
              onTap: () {
                playlistState.toggleFavorite(song);
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_to_photos_outlined),
              title: const Text('Add to playlist'),
              onTap: () {
                Navigator.pop(sheetContext);
                showAddToPlaylistSheet(context, [song]);
              },
            ),
          ],
        ),
      );
    },
  );
}
