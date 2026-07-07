import 'package:flutter/material.dart' hide RepeatMode;
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/player_state.dart';
import '../../state/playlist_state.dart';
import '../../widgets/artwork.dart';
import '../../widgets/song_tile.dart';

class PlayerTab extends StatelessWidget {
  final Color? dominantColor;
  const PlayerTab({super.key, this.dominantColor});

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final playlistState = context.watch<PlaylistState>();
    final song = playerState.currentSong;
    final scheme = Theme.of(context).colorScheme;

    if (song == null) {
      return const Center(child: Text('Nothing is playing'));
    }

    final isFavorite = playlistState.isFavorite(song);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => Artwork(
                id: song.albumId,
                type: ArtworkType.ALBUM,
                size: constraints.maxWidth,
                radius: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${song.artist} • ${song.album}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : null),
                onPressed: () => playlistState.toggleFavorite(song),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showSongActionsSheet(context, song),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<Duration>(
            stream: playerState.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = playerState.duration;
              final maxMs = duration.inMilliseconds.toDouble();
              final valueMs = position.inMilliseconds.toDouble().clamp(0, maxMs <= 0 ? 1 : maxMs);
              return Column(
                children: [
                  Slider(
                    value: valueMs.toDouble(),
                    max: maxMs <= 0 ? 1 : maxMs,
                    onChanged: (v) => playerState.seek(Duration(milliseconds: v.round())),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(position)),
                        Text(formatDuration(duration)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle,
                    color: playerState.shuffleEnabled ? scheme.primary : scheme.onSurfaceVariant),
                onPressed: () => playerState.setShuffle(!playerState.shuffleEnabled),
              ),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.skip_previous_rounded),
                onPressed: playerState.skipPrevious,
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: FilledButton(
                  style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                  onPressed: playerState.togglePlayPause,
                  child: Icon(
                    playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                  ),
                ),
              ),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: playerState.skipNext,
              ),
              IconButton(
                icon: Icon(
                  switch (playerState.repeatMode) {
                    RepeatMode.off => Icons.repeat,
                    RepeatMode.all => Icons.repeat,
                    RepeatMode.one => Icons.repeat_one,
                  },
                  color: playerState.repeatMode == RepeatMode.off ? scheme.onSurfaceVariant : scheme.primary,
                ),
                onPressed: playerState.cycleRepeatMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
