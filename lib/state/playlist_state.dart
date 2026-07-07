import 'package:flutter/foundation.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_store.dart';

const favoritesPlaylistId = 'favorites';

class PlaylistState extends ChangeNotifier {
  final PlaylistStore _store;
  PlaylistState(this._store);

  List<Playlist> playlists = [];

  Future<void> init() async {
    await _store.init();
    if (_store.byId(favoritesPlaylistId) == null) {
      final fav = Playlist(id: favoritesPlaylistId, name: 'Favorites', createdAt: DateTime.now());
      await _store.save(fav);
    }
    refresh();
  }

  void refresh() {
    playlists = _store.all();
    notifyListeners();
  }

  Playlist get favorites => _store.byId(favoritesPlaylistId)!;

  bool isFavorite(Song song) => favorites.songPaths.contains(song.data);

  Future<void> toggleFavorite(Song song) async {
    final fav = favorites;
    if (fav.songPaths.contains(song.data)) {
      fav.songPaths.remove(song.data);
    } else {
      fav.addSong(song);
    }
    await _store.save(fav);
    refresh();
  }

  /// Creates a playlist from an arbitrary set of songs (used for both the
  /// "add individual files" and "add whole folder" creation flows). There is
  /// no limit on how many songs can be passed in.
  Future<Playlist> createPlaylist(String name, {Iterable<Song> songs = const []}) async {
    final playlist = await _store.create(name, songs: songs);
    refresh();
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    if (id == favoritesPlaylistId) return;
    await _store.delete(id);
    refresh();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    await _store.rename(id, newName);
    refresh();
  }

  Future<void> addSongsToPlaylist(String id, Iterable<Song> songs) async {
    await _store.addSongs(id, songs);
    refresh();
  }

  Future<void> removeSongAt(String id, int index) async {
    await _store.removeSongAt(id, index);
    refresh();
  }

  Future<void> reorder(String id, int oldIndex, int newIndex) async {
    await _store.reorder(id, oldIndex, newIndex);
    refresh();
  }
}
