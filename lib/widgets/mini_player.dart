import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../screens/now_playing/now_playing_screen.dart';
import '../state/player_state.dart';
import 'artwork.dart';

/// Docked bar shown above the tab content whenever something is loaded,
/// mirroring Samsung Music's persistent mini-player.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final song = playerState.currentSong;
    if (song == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<Duration>(
                stream: playerState.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = playerState.duration;
                  final progress = duration.inMilliseconds == 0
                      ? 0.0
                      : (position.inMilliseconds / duration.inMilliseconds)
                            .clamp(0.0, 1.0);
                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(scheme.primary),
                  );
                },
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Artwork(
                      id: song.albumId,
                      type: ArtworkType.ALBUM,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: playerState.skipPrevious,
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                      onPressed: playerState.togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: playerState.skipNext,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
