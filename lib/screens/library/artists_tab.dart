import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../../widgets/artwork.dart';
import 'artist_detail_screen.dart';

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final artists = library.artists;

    if (artists.isEmpty) return const Center(child: Text('No artists found.'));

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: ClipOval(
            child: Artwork(id: artist.id, type: ArtworkType.ARTIST, size: 48),
          ),
          title: Text(artist.artist),
          subtitle: Text('${artist.numberOfTracks ?? 0} songs'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArtistDetailScreen(artistId: artist.id, artistName: artist.artist),
            ),
          ),
        );
      },
    );
  }
}
