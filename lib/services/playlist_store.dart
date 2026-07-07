import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/playlist.dart';
import '../models/song.dart';

/// Persists playlists as plain maps in a Hive box. There is no cap on the
/// number of songs a playlist can hold - `songPaths` is a growable list
/// with no bound checks anywhere in this class.
class PlaylistStore {
  static const _boxName = 'playlists';
  late Box _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<Playlist> all() {
    return _box.values
        .map((raw) => Playlist.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Playlist? byId(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return Playlist.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<Playlist> create(String name, {Iterable<Song> songs = const []}) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    playlist.addAll(songs);
    await _box.put(playlist.id, playlist.toMap());
    return playlist;
  }

  Future<void> save(Playlist playlist) async {
    await _box.put(playlist.id, playlist.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> rename(String id, String newName) async {
    final playlist = byId(id);
    if (playlist == null) return;
    playlist.name = newName;
    await save(playlist);
  }

  Future<void> addSongs(String id, Iterable<Song> songs) async {
    final playlist = byId(id);
    if (playlist == null) return;
    playlist.addAll(songs);
    await save(playlist);
  }

  Future<void> removeSongAt(String id, int index) async {
    final playlist = byId(id);
    if (playlist == null) return;
    playlist.removeAt(index);
    await save(playlist);
  }

  Future<void> reorder(String id, int oldIndex, int newIndex) async {
    final playlist = byId(id);
    if (playlist == null) return;
    playlist.reorder(oldIndex, newIndex);
    await save(playlist);
  }
}
