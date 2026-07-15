import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../state/library_state.dart';
import '../../state/playlist_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/artwork.dart';
import '../playlists/create_playlist_screen.dart';
import '../playlists/playlist_detail_screen.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistState = context.watch<PlaylistState>();
    final library = context.watch<LibraryState>();
    final playlists = playlistState.playlists;
    final scheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.unit,
        AppSpacing.containerMargin,
        AppSpacing.sectionGap,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.gutter,
        crossAxisSpacing: AppSpacing.gutter,
        childAspectRatio: 0.8,
      ),
      itemCount: playlists.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CreatePlaylistCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreatePlaylistScreen()),
            ),
          );
        }
        final Playlist playlist = playlists[index - 1];
        final isFavorites = playlist.id == favoritesPlaylistId;
        final firstSong = library.byPaths(playlist.songPaths).firstOrNull;

        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.dflt),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: playlist.id)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: firstSong != null
                    ? LayoutBuilder(
                        builder: (context, constraints) => Artwork(
                          id: firstSong.albumId,
                          type: ArtworkType.ALBUM,
                          size: constraints.maxWidth,
                          radius: AppRadii.dflt,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadii.dflt),
                        ),
                        child: Icon(
                          isFavorites ? Icons.favorite : Icons.queue_music,
                          size: 40,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.unit),
              Text(playlist.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              Text('${playlist.songPaths.length} tracks',
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );
      },
    );
  }
}

class _CreatePlaylistCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreatePlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.dflt),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.dflt),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.add, color: scheme.primary),
            ),
            const SizedBox(height: AppSpacing.elementGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Create New Playlist',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
