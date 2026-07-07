import 'package:on_audio_query/on_audio_query.dart';

/// A lightweight, storage-friendly representation of a track.
///
/// Wrapping [SongModel] lets playlists persist songs as plain maps (so they
/// survive across library rescans) while still being buildable straight from
/// a fresh MediaStore query result.
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int albumId;
  final int artistId;
  final String data;
  final int durationMs;
  final int? size;
  final String? genre;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.artistId,
    required this.data,
    required this.durationMs,
    this.size,
    this.genre,
  });

  factory Song.fromQuery(SongModel m) {
    return Song(
      id: m.id,
      title: m.title,
      artist: (m.artist == null || m.artist!.trim().isEmpty) ? 'Unknown artist' : m.artist!,
      album: (m.album == null || m.album!.trim().isEmpty) ? 'Unknown album' : m.album!,
      albumId: m.albumId ?? -1,
      artistId: m.artistId ?? -1,
      data: m.data,
      durationMs: m.duration ?? 0,
      size: m.size,
      genre: m.genre,
    );
  }

  String get folderPath {
    final idx = data.lastIndexOf(RegExp(r'[\\/]'));
    return idx == -1 ? data : data.substring(0, idx);
  }

  String get folderName {
    final parts = folderPath.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? folderPath : parts.last;
  }

  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'albumId': albumId,
        'artistId': artistId,
        'data': data,
        'durationMs': durationMs,
        'size': size,
        'genre': genre,
      };

  factory Song.fromMap(Map map) => Song(
        id: map['id'] as int,
        title: map['title'] as String,
        artist: map['artist'] as String,
        album: map['album'] as String,
        albumId: map['albumId'] as int,
        artistId: map['artistId'] as int,
        data: map['data'] as String,
        durationMs: map['durationMs'] as int,
        size: map['size'] as int?,
        genre: map['genre'] as String?,
      );

  @override
  bool operator ==(Object other) => other is Song && other.data == data;

  @override
  int get hashCode => data.hashCode;
}
