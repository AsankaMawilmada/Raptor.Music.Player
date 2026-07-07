import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart' show AlbumModel, ArtistModel;

import '../models/song.dart';
import '../services/library_service.dart';

enum LibraryLoadStatus { loading, needsPermission, ready, error }

class LibraryState extends ChangeNotifier {
  final LibraryService _service;
  LibraryState(this._service);

  LibraryLoadStatus status = LibraryLoadStatus.loading;
  List<Song> songs = [];
  List<AlbumModel> albums = [];
  List<ArtistModel> artists = [];
  List<MusicFolder> folders = [];
  SongSort sort = SongSort.titleAsc;
  String searchQuery = '';

  Future<void> init() async {
    final granted = await _service.hasPermission();
    if (!granted) {
      status = LibraryLoadStatus.needsPermission;
      notifyListeners();
      return;
    }
    await load();
  }

  Future<void> requestPermissionAndLoad() async {
    final granted = await _service.requestPermission();
    if (!granted) {
      status = LibraryLoadStatus.needsPermission;
      notifyListeners();
      return;
    }
    await load();
  }

  Future<void> load() async {
    status = LibraryLoadStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchAllSongs(),
        _service.fetchAlbums(),
        _service.fetchArtists(),
      ]);
      songs = results[0] as List<Song>;
      albums = results[1] as List<AlbumModel>;
      artists = results[2] as List<ArtistModel>;
      folders = _service.groupIntoFolders(songs);
      status = LibraryLoadStatus.ready;
    } catch (_) {
      status = LibraryLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> rescan() => load();

  void setSort(SongSort newSort) {
    sort = newSort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<Song> get sortedSongs => _service.sortSongs(songs, sort);

  List<Song> get filteredSongs {
    final base = sortedSongs;
    if (searchQuery.trim().isEmpty) return base;
    final q = searchQuery.toLowerCase();
    return base
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }

  List<Song> songsForAlbum(int albumId) => songs.where((s) => s.albumId == albumId).toList();
  List<Song> songsForArtist(int artistId) => songs.where((s) => s.artistId == artistId).toList();

  Song? byPath(String path) {
    for (final s in songs) {
      if (s.data == path) return s;
    }
    return null;
  }

  List<Song> byPaths(List<String> paths) {
    final result = <Song>[];
    for (final p in paths) {
      final s = byPath(p);
      if (s != null) result.add(s);
    }
    return result;
  }
}
