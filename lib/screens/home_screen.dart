import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/library_service.dart';
import '../state/library_state.dart';
import '../widgets/mini_player.dart';
import 'library/albums_tab.dart';
import 'library/artists_tab.dart';
import 'library/folders_tab.dart';
import 'library/playlists_tab.dart';
import 'library/songs_tab.dart';
import 'playlists/create_playlist_screen.dart';
import 'search_screen.dart';
import 'settings/equalizer_screen.dart';
import 'settings/sleep_timer_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  static const _tabs = ['Tracks', 'Playlists', 'Albums', 'Artists', 'Folders'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabIndex) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryState>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New playlist'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
              ),
            )
          : null,
      body: _buildBody(library),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildBody(LibraryState library) {
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
                  'Raptor Player needs access to your music to build your library.',
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
        return TabBarView(
          controller: _tabController,
          children: const [
            SongsTab(),
            PlaylistsTab(),
            AlbumsTab(),
            ArtistsTab(),
            FoldersTab(),
          ],
        );
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
