import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/player_state.dart';

void showSleepTimerSheet(BuildContext context) {
  final playerState = context.read<PlayerState>();
  final sleepTimer = playerState.sleepTimer;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: AnimatedBuilder(
          animation: sleepTimer,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text('Sleep timer', style: Theme.of(context).textTheme.titleMedium),
                ),
                if (sleepTimer.isActive)
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(sleepTimer.endOfTrackArmed
                        ? 'Stopping at the end of this track'
                        : 'Stopping in ${_format(sleepTimer.remaining ?? Duration.zero)}'),
                    trailing: TextButton(
                      onPressed: () => sleepTimer.cancel(),
                      child: const Text('Cancel'),
                    ),
                  )
                else ...[
                  for (final minutes in [5, 15, 30, 45, 60, 90])
                    ListTile(
                      leading: const Icon(Icons.timer_outlined),
                      title: Text('$minutes minutes'),
                      onTap: () {
                        sleepTimer.onFire = () => playerState.player.pause();
                        sleepTimer.startCountdown(Duration(minutes: minutes));
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('End of current track'),
                    onTap: () {
                      sleepTimer.onFire = () => playerState.player.pause();
                      sleepTimer.armEndOfTrack();
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ],
            );
          },
        ),
      );
    },
  );
}

String _format(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
