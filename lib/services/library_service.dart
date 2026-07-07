import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';

import '../models/song.dart';

enum SongSort { titleAsc, artistAsc, albumAsc, dateAddedDesc, durationDesc }

class MusicFolder {
  final String path;
  final String name;
  final List<Song> songs;
  MusicFolder({required this.path, required this.name, required this.songs});
}

/// Thin wrapper around [OnAudioQuery] (MediaStore) that owns permission
/// handling and exposes the raw library as our own [Song] model plus
/// folder/album/artist groupings.
class LibraryService {
  final OnAudioQuery _query = OnAudioQuery();

  Future<bool> hasPermission() => _query.checkAndRequest(retryRequest: false);

  Future<bool> requestPermission() => _query.checkAndRequest(retryRequest: true);

  Future<List<Song>> fetchAllSongs() async {
    final songs = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    return songs
        .where((s) => s.isMusic ?? true)
        .map(Song.fromQuery)
        .toList(growable: false);
  }

  Future<List<AlbumModel>> fetchAlbums() => _query.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
      );

  Future<List<ArtistModel>> fetchArtists() => _query.queryArtists(
        sortType: ArtistSortType.ARTIST,
        orderType: OrderType.ASC_OR_SMALLER,
      );

  Future<List<Song>> songsForAlbum(int albumId, List<Song> all) async {
    return all.where((s) => s.albumId == albumId).toList();
  }

  Future<List<Song>> songsForArtist(int artistId, List<Song> all) async {
    return all.where((s) => s.artistId == artistId).toList();
  }

  List<MusicFolder> groupIntoFolders(List<Song> songs) {
    final Map<String, List<Song>> byFolder = {};
    for (final s in songs) {
      byFolder.putIfAbsent(s.folderPath, () => []).add(s);
    }
    final folders = byFolder.entries
        .map((e) => MusicFolder(path: e.key, name: _lastSegment(e.key), songs: e.value))
        .toList();
    folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return folders;
  }

  String _lastSegment(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty && parts.last.isNotEmpty ? parts.last : path;
  }

  List<Song> sortSongs(List<Song> songs, SongSort sort) {
    final copy = List<Song>.from(songs);
    switch (sort) {
      case SongSort.titleAsc:
        copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSort.artistAsc:
        copy.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case SongSort.albumAsc:
        copy.sort((a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()));
        break;
      case SongSort.dateAddedDesc:
        copy.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SongSort.durationDesc:
        copy.sort((a, b) => b.durationMs.compareTo(a.durationMs));
        break;
    }
    return copy;
  }

  Future<Uint8List?> artworkBytes(int id, {ArtworkType type = ArtworkType.AUDIO}) async {
    return _query.queryArtwork(id, type, size: 400, quality: 90);
  }
}
