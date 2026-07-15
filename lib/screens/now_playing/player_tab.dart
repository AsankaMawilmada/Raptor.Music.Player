import 'package:flutter/material.dart' hide RepeatMode;
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/player_state.dart';
import '../../state/playlist_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/artwork.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_seek_bar.dart';
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerMargin,
              AppSpacing.unit,
              AppSpacing.containerMargin,
              AppSpacing.elementGap,
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Artwork(
                            id: song.albumId,
                            type: ArtworkType.ALBUM,
                            size: constraints.maxWidth,
                            radius: AppRadii.lg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Text(
                  'Playing from ${playerState.queueSourceLabel ?? 'Library'}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.unit),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${song.artist} • ${song.album}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? scheme.primary : null),
                      onPressed: () => playlistState.toggleFavorite(song),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => showSongActionsSheet(context, song),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            0,
            AppSpacing.containerMargin,
            AppSpacing.containerMargin + bottomInset,
          ),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: playerState.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = playerState.duration;
                    final maxMs = duration.inMilliseconds.toDouble();
                    final progress = maxMs <= 0 ? 0.0 : (position.inMilliseconds / maxMs).clamp(0.0, 1.0);
                    return Column(
                      children: [
                        GradientSeekBar(
                          value: progress,
                          onChanged: maxMs <= 0
                              ? null
                              : (v) => playerState.seek(Duration(milliseconds: (v * maxMs).round())),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDuration(position), style: Theme.of(context).textTheme.labelSmall),
                              Text(formatDuration(duration), style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.unit),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle,
                          color: playerState.shuffleEnabled ? scheme.primary : scheme.onSurfaceVariant),
                      onPressed: () => playerState.setShuffle(!playerState.shuffleEnabled),
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: playerState.skipPrevious,
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppGradients.vibrant,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: playerState.togglePlayPause,
                        icon: Icon(
                          playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 32,
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
          ),
        ),
      ],
    );
  }
}
