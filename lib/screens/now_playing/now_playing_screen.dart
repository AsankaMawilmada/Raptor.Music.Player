import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../../services/artwork_cache_service.dart';
import '../../state/app_nav_state.dart';
import '../../state/player_state.dart';
import '../../widgets/app_bottom_nav.dart';
import '../playlists/add_to_playlist_sheet.dart';
import '../settings/equalizer_screen.dart';
import '../settings/sleep_timer_sheet.dart';
import 'lyrics_tab.dart';
import 'player_tab.dart';
import 'queue_tab.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  Color? _dominantColor;
  int? _lastAlbumId;

  Future<void> _updatePalette(int albumId) async {
    if (_lastAlbumId == albumId) return;
    _lastAlbumId = albumId;
    final artworkCache = context.read<ArtworkCacheService>();
    final file = await artworkCache.fileForAlbum(albumId);
    if (file == null) {
      if (mounted) setState(() => _dominantColor = null);
      return;
    }
    try {
      final palette = await PaletteGenerator.fromImageProvider(FileImage(File(file.path)));
      if (mounted) {
        setState(() => _dominantColor = palette.dominantColor?.color);
      }
    } catch (_) {
      if (mounted) setState(() => _dominantColor = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();
    final song = playerState.currentSong;
    final scheme = Theme.of(context).colorScheme;

    if (song != null) {
      _updatePalette(song.albumId);
    }

    final baseColor = _dominantColor ?? scheme.surface;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [baseColor.withValues(alpha: 0.55), scheme.surface],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var i = 0; i < appNavDestinations.length; i++)
                            IconButton(
                              icon: Icon(appNavDestinations[i].icon),
                              tooltip: appNavDestinations[i].label,
                              color: scheme.onSurfaceVariant,
                              onPressed: () {
                                context.read<AppNavState>().setIndex(i);
                                Navigator.of(context).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _onMenu(context, value, playerState),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'add_playlist', child: Text('Add to playlist')),
                        PopupMenuItem(value: 'equalizer', child: Text('Equalizer')),
                        PopupMenuItem(value: 'sleep_timer', child: Text('Sleep timer')),
                      ],
                    ),
                  ],
                ),
                TabBar(tabs: const [
                  Tab(text: 'Player'),
                  Tab(text: 'Lyrics'),
                  Tab(text: 'Up next'),
                ], labelStyle: Theme.of(context).textTheme.labelMedium),
                Expanded(
                  child: TabBarView(
                    children: [
                      PlayerTab(dominantColor: _dominantColor),
                      const LyricsTab(),
                      const QueueTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMenu(BuildContext context, String value, PlayerState playerState) {
    switch (value) {
      case 'add_playlist':
        final song = playerState.currentSong;
        if (song != null) showAddToPlaylistSheet(context, [song]);
        break;
      case 'equalizer':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EqualizerScreen()));
        break;
      case 'sleep_timer':
        showSleepTimerSheet(context);
        break;
    }
  }
}
