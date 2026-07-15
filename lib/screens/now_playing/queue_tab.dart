import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/player_state.dart';
import '../../widgets/artwork.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final queue = playerState.queue;
    final currentIndex = playerState.currentIndex ?? -1;

    if (queue.isEmpty) return const Center(child: Text('Queue is empty'));

    return ReorderableListView.builder(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: queue.length,
      onReorder: (oldIndex, newIndex) => playerState.reorderQueue(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final song = queue[index];
        final isCurrent = index == currentIndex;
        return Dismissible(
          key: ValueKey('${song.data}_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete),
          ),
          onDismissed: (_) => playerState.removeFromQueueAt(index),
          child: ListTile(
            leading: Artwork(id: song.albumId, type: ArtworkType.ALBUM, size: 44),
            title: Text(song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                )),
            subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: isCurrent
                ? Icon(Icons.equalizer, color: Theme.of(context).colorScheme.primary)
                : ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
            onTap: () => playerState.jumpTo(index),
          ),
        );
      },
    );
  }
}
