import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/artwork.dart';
import 'album_detail_screen.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final albums = library.albums;

    if (albums.isEmpty) return const Center(child: Text('No albums found.'));

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.dflt),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: album.id, albumName: album.album)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) => Artwork(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    size: constraints.maxWidth,
                    radius: AppRadii.dflt,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.unit),
              Text(album.album,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              Text(album.artist ?? 'Unknown artist',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );
      },
    );
  }
}
