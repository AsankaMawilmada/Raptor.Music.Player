import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' show ArtworkType, QueryArtworkWidget;

/// Rounded-square album/track artwork with a Samsung-Music-like fallback
/// (a music note glyph on a muted tile) when no embedded art exists.
class Artwork extends StatelessWidget {
  final int id;
  final ArtworkType type;
  final double size;
  final double radius;

  const Artwork({
    super.key,
    required this.id,
    this.type = ArtworkType.AUDIO,
    this.size = 48,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _placeholder(context);
    if (id < 0) return placeholder;
    return QueryArtworkWidget(
      id: id,
      type: type,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(radius),
      artworkWidth: size,
      artworkHeight: size,
      keepOldArtwork: true,
      nullArtworkWidget: placeholder,
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.music_note_rounded, color: scheme.onSurfaceVariant, size: size * 0.5),
    );
  }
}
