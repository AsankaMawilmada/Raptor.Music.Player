import 'package:hive_flutter/hive_flutter.dart';

import '../models/song.dart';
import '../state/library_state.dart';

/// Tracks the most recently played song paths in a small capped Hive box,
/// most-recent-first, for the Home tab's "Recently Played" row.
class RecentPlaysService {
  static const _boxName = 'recent_plays';
  static const _key = 'paths';
  static const _maxEntries = 20;
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> recordPlay(Song song) async {
    final paths = _paths()..remove(song.data);
    paths.insert(0, song.data);
    if (paths.length > _maxEntries) paths.removeRange(_maxEntries, paths.length);
    await _box.put(_key, paths);
  }

  List<String> _paths() => (_box.get(_key) as List?)?.cast<String>() ?? [];

  List<Song> recentSongs(LibraryState library) => library.byPaths(_paths());
}
