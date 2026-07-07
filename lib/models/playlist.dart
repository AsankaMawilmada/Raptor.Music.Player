import 'song.dart';

/// A user playlist. Songs are kept as an ordered, uncapped list of file
/// paths (the stable identifier) resolved against the live library when
/// displayed, so a playlist can hold any number of tracks.
class Playlist {
  final String id;
  String name;
  final DateTime createdAt;
  final List<String> songPaths;

  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    List<String>? songPaths,
  }) : songPaths = songPaths ?? <String>[];

  void addAll(Iterable<Song> songs) {
    for (final s in songs) {
      if (!songPaths.contains(s.data)) {
        songPaths.add(s.data);
      }
    }
  }

  void addSong(Song song) {
    if (!songPaths.contains(song.data)) songPaths.add(song.data);
  }

  void removeAt(int index) => songPaths.removeAt(index);

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = songPaths.removeAt(oldIndex);
    songPaths.insert(newIndex, item);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'songPaths': songPaths,
      };

  factory Playlist.fromMap(Map map) => Playlist(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        songPaths: (map['songPaths'] as List).cast<String>(),
      );
}
