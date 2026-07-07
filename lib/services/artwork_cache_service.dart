import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart' show ArtworkType;
import 'package:path_provider/path_provider.dart';

import 'library_service.dart';

/// Writes queried album/track artwork bytes to a cache file so they can be
/// referenced by a `file://` [Uri] (needed for the lock-screen MediaItem
/// artwork, which just_audio_background reads from a plain Uri).
class ArtworkCacheService {
  final LibraryService _library;
  Directory? _dir;
  final Set<int> _missing = {};

  ArtworkCacheService(this._library);

  Future<Directory> _cacheDir() async {
    if (_dir != null) return _dir!;
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/artwork_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  /// Returns a cached artwork file for the given album, fetching and
  /// writing it the first time it's requested. Returns null if the track
  /// has no embedded artwork.
  Future<File?> fileForAlbum(int albumId) async {
    if (_missing.contains(albumId)) return null;
    final dir = await _cacheDir();
    final file = File('${dir.path}/album_$albumId.png');
    if (await file.exists()) return file;
    final bytes = await _library.artworkBytes(albumId, type: ArtworkType.ALBUM);
    if (bytes == null || bytes.isEmpty) {
      _missing.add(albumId);
      return null;
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
