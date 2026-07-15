import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/library_service.dart';
import '../state/app_nav_state.dart';
import '../state/library_state.dart';
import '../state/playlist_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/mini_player.dart';
import 'home/home_tab.dart';
import 'library/playlists_tab.dart';
import 'library/songs_tab.dart';
import 'playlists/create_playlist_screen.dart';
import 'playlists/playlist_detail_screen.dart';
import 'search_screen.dart';
import 'settings/equalizer_screen.dart';
import 'settings/sleep_timer_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final navIndex = context.watch<AppNavState>().index;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note_rounded),
            const SizedBox(width: AppSpacing.unit),
            const Text('Lyd'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'sort', child: Text('Sort by')),
              PopupMenuItem(value: 'equalizer', child: Text('Equalizer')),
              PopupMenuItem(value: 'sleep_timer', child: Text('Sleep timer')),
              PopupMenuItem(value: 'rescan', child: Text('Rescan library')),
            ],
          ),
        ],
      ),
      floatingActionButton: navIndex == 2
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New playlist'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
              ),
            )
          : null,
      body: _buildBody(library, navIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          AppBottomNavBar(
            currentIndex: navIndex,
            onTap: (index) => context.read<AppNavState>().setIndex(index),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LibraryState library, int navIndex) {
    switch (library.status) {
      case LibraryLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LibraryLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your music library.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<LibraryState>().load(),
                child: const Text('Try again'),
              ),
            ],
          ),
        );
      case LibraryLoadStatus.needsPermission:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.audiotrack, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Lyd needs access to your music to build your library.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<LibraryState>().requestPermissionAndLoad(),
                  child: const Text('Grant access'),
                ),
              ],
            ),
          ),
        );
      case LibraryLoadStatus.ready:
        return switch (navIndex) {
          0 => const HomeTab(),
          1 => const PlaylistSongsView(playlistId: favoritesPlaylistId),
          2 => const PlaylistsTab(),
          _ => const SongsTab(),
        };
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'sort':
        _showSortSheet(context);
        break;
      case 'equalizer':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EqualizerScreen()));
        break;
      case 'sleep_timer':
        showSleepTimerSheet(context);
        break;
      case 'rescan':
        context.read<LibraryState>().rescan();
        break;
    }
  }

  void _showSortSheet(BuildContext context) {
    final library = context.read<LibraryState>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in {
              SongSort.titleAsc: 'Title',
              SongSort.artistAsc: 'Artist',
              SongSort.albumAsc: 'Album',
              SongSort.dateAddedDesc: 'Recently added',
              SongSort.durationDesc: 'Duration',
            }.entries)
              RadioListTile<SongSort>(
                value: entry.key,
                groupValue: library.sort,
                title: Text(entry.value),
                onChanged: (value) {
                  if (value != null) library.setSort(value);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}
