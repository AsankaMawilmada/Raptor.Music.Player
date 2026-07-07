import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/lyrics_service.dart';
import '../../state/player_state.dart';

class LyricsTab extends StatefulWidget {
  const LyricsTab({super.key});

  @override
  State<LyricsTab> createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final _scrollController = ScrollController();
  static const _rowHeight = 40.0;
  int _lastScrolledIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final lyricsService = context.read<LyricsService>();
    final song = playerState.currentSong;

    if (song == null) return const Center(child: Text('Nothing is playing'));

    return FutureBuilder<LyricsResult>(
      future: lyricsService.lyricsFor(song.data),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data;
        if (result == null || !result.hasLyrics) {
          return const Center(child: Text('No lyrics found for this track.'));
        }
        if (result.isSynced) {
          return StreamBuilder<Duration>(
            stream: playerState.positionStream,
            builder: (context, posSnapshot) {
              final position = posSnapshot.data ?? Duration.zero;
              final lines = result.synced!;
              var currentIndex = 0;
              for (var i = 0; i < lines.length; i++) {
                if (lines[i].timestamp <= position) currentIndex = i;
              }
              _maybeScrollTo(currentIndex);
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.3),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == currentIndex;
                  return SizedBox(
                    height: _rowHeight,
                    child: Center(
                      child: Text(
                        lines[index].text.isEmpty ? '♪' : lines[index].text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isCurrent ? 18 : 15,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(result.plain ?? '', style: const TextStyle(fontSize: 15, height: 1.6)),
        );
      },
    );
  }

  void _maybeScrollTo(int index) {
    if (index == _lastScrolledIndex) return;
    _lastScrolledIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        index * _rowHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
