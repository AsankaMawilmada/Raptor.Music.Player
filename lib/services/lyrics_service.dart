import 'dart:io';

import 'package:audiotags/audiotags.dart';

class LyricLine {
  final Duration timestamp;
  final String text;
  const LyricLine(this.timestamp, this.text);
}

class LyricsResult {
  final List<LyricLine>? synced;
  final String? plain;
  const LyricsResult({this.synced, this.plain});

  bool get hasLyrics => (synced != null && synced!.isNotEmpty) || (plain != null && plain!.trim().isNotEmpty);
  bool get isSynced => synced != null && synced!.isNotEmpty;
}

/// Looks up lyrics for a track: first an embedded tag, then a sibling
/// `.lrc` file (time-synced) or `.txt` file next to the audio file.
class LyricsService {
  final Map<String, LyricsResult> _cache = {};

  Future<LyricsResult> lyricsFor(String audioPath) async {
    if (_cache.containsKey(audioPath)) return _cache[audioPath]!;

    final lrc = await _lrcSibling(audioPath);
    if (lrc != null) {
      final result = LyricsResult(synced: lrc);
      _cache[audioPath] = result;
      return result;
    }

    final embedded = await _embeddedLyrics(audioPath);
    if (embedded != null && embedded.trim().isNotEmpty) {
      final result = LyricsResult(plain: embedded);
      _cache[audioPath] = result;
      return result;
    }

    const empty = LyricsResult();
    _cache[audioPath] = empty;
    return empty;
  }

  Future<String?> _embeddedLyrics(String audioPath) async {
    try {
      final tag = await AudioTags.read(audioPath);
      return tag?.lyrics;
    } catch (_) {
      return null;
    }
  }

  Future<List<LyricLine>?> _lrcSibling(String audioPath) async {
    final dot = audioPath.lastIndexOf('.');
    final base = dot == -1 ? audioPath : audioPath.substring(0, dot);
    final lrcFile = File('$base.lrc');
    if (!await lrcFile.exists()) return null;
    try {
      final content = await lrcFile.readAsString();
      return _parseLrc(content);
    } catch (_) {
      return null;
    }
  }

  List<LyricLine> _parseLrc(String content) {
    final lineRegex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{1,3}))?\]');
    final lines = <LyricLine>[];
    for (final rawLine in content.split('\n')) {
      final matches = lineRegex.allMatches(rawLine).toList();
      if (matches.isEmpty) continue;
      final text = rawLine.replaceAll(lineRegex, '').trim();
      for (final m in matches) {
        final minutes = int.parse(m.group(1)!);
        final seconds = int.parse(m.group(2)!);
        final fraction = m.group(3);
        final millis = fraction == null
            ? 0
            : int.parse(fraction.padRight(3, '0').substring(0, 3));
        lines.add(LyricLine(
          Duration(minutes: minutes, seconds: seconds, milliseconds: millis),
          text,
        ));
      }
    }
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }
}
