import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../screens/now_playing/now_playing_screen.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';
import 'glass_container.dart';
import 'gradient_seek_bar.dart';

/// Floating glass mini-player docked above the bottom nav bar, mirroring
/// the Lumina Audio design system's "glass-player" component.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final song = playerState.currentSong;
    if (song == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const NowPlayingScreen(),
            transitionsBuilder: (_, animation, _, child) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        ),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(AppRadii.dflt),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4)),
          ],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Artwork(id: song.albumId, type: ArtworkType.ALBUM, size: 44, radius: AppRadii.sm),
                    const SizedBox(width: AppSpacing.elementGap),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: playerState.skipPrevious,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.vibrant,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 22,
                        color: Colors.white,
                        icon: Icon(
                          playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        ),
                        onPressed: playerState.togglePlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: playerState.skipNext,
                    ),
                  ],
                ),
                StreamBuilder<Duration>(
                  stream: playerState.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = playerState.duration;
                    final progress = duration.inMilliseconds == 0
                        ? 0.0
                        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
                    return GradientSeekBar(value: progress, trackHeight: 3, showHandle: false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
