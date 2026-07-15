import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../services/recent_plays_service.dart';
import '../../state/library_state.dart';
import '../../state/player_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/artwork.dart';
import '../library/albums_tab.dart';
import '../library/artists_tab.dart';
import '../library/folders_tab.dart';
import '../library/library_section_screen.dart';
import '../search_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    // Rebuilds whenever playback starts, so the recently-played row updates.
    context.watch<PlayerState>();
    final recentPlays = context.read<RecentPlaysService>();
    final recentSongs = recentPlays.recentSongs(library);
    final playerState = context.read<PlayerState>();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.unit,
            AppSpacing.containerMargin,
            0,
          ),
          child: _SearchBar(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ),
        if (recentSongs.isNotEmpty) ...[
          _SectionHeader(title: 'Recently Played'),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
              itemCount: recentSongs.length,
              itemBuilder: (context, index) {
                final song = recentSongs[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.gutter),
                  child: SizedBox(
                    width: 140,
                    child: GestureDetector(
                      onTap: () => playerState.playQueue(
                        recentSongs,
                        startIndex: index,
                        sourceLabel: 'Recently played',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Artwork(id: song.albumId, type: ArtworkType.ALBUM, size: 140, radius: AppRadii.dflt),
                          const SizedBox(height: AppSpacing.unit),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        _SectionHeader(title: 'Browse'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
          child: Row(
            children: [
              Expanded(
                child: _BrowseCard(
                  icon: Icons.album_rounded,
                  label: 'Albums',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LibrarySectionScreen(title: 'Albums', child: AlbumsTab()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: _BrowseCard(
                  icon: Icons.person_rounded,
                  label: 'Artists',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LibrarySectionScreen(title: 'Artists', child: ArtistsTab()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: _BrowseCard(
                  icon: Icons.folder_rounded,
                  label: 'Folders',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LibrarySectionScreen(title: 'Folders', child: FoldersTab()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (recentSongs.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerMargin,
              AppSpacing.sectionGap,
              AppSpacing.containerMargin,
              0,
            ),
            child: Text(
              'Play something to see it here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.sectionGap,
        AppSpacing.containerMargin,
        AppSpacing.elementGap,
      ),
      child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.full),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.elementGap),
              Text(
                'Search your library',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BrowseCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.dflt),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.dflt),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(height: AppSpacing.unit),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
