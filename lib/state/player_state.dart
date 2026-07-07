import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/song.dart';
import '../services/artwork_cache_service.dart';
import '../services/sleep_timer_service.dart';

enum RepeatMode { off, all, one }

/// Central playback engine. Wraps a single [AudioPlayer] whose playlist can
/// be arbitrarily long, reordered, and shuffled, while just_audio_background
/// keeps the lock screen / notification controls in sync automatically.
class PlayerState extends ChangeNotifier {
  final ArtworkCacheService artworkCache;
  final SleepTimerService sleepTimer;

  late final AndroidEqualizer equalizer;
  late final AudioPlayer player;

  bool _hasQueue = false;
  List<Song> _queue = [];
  String? _queueSourceLabel;
  int? _lastIndex;

  PlayerState({required this.artworkCache, required this.sleepTimer}) {
    equalizer = AndroidEqualizer();
    player = AudioPlayer(
      audioPipeline: AudioPipeline(androidAudioEffects: [equalizer]),
    );
    player.currentIndexStream.listen((index) {
      if (_lastIndex != null && index != null && index != _lastIndex) {
        sleepTimer.notifyTrackEnded();
      }
      _lastIndex = index;
      notifyListeners();
    });
    player.playingStream.listen((_) => notifyListeners());
    player.processingStateStream.listen((state) {
      notifyListeners();
    });
  }

  List<Song> get queue => List.unmodifiable(_queue);
  String? get queueSourceLabel => _queueSourceLabel;
  int? get currentIndex => player.currentIndex;
  Song? get currentSong =>
      (currentIndex != null && currentIndex! >= 0 && currentIndex! < _queue.length)
          ? _queue[currentIndex!]
          : null;
  bool get isPlaying => player.playing;
  bool get isBuffering =>
      player.processingState == ProcessingState.loading ||
      player.processingState == ProcessingState.buffering;
  Duration get position => player.position;
  Duration get duration => player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  bool get shuffleEnabled => player.shuffleModeEnabled;
  RepeatMode get repeatMode => switch (player.loopMode) {
        LoopMode.off => RepeatMode.off,
        LoopMode.all => RepeatMode.all,
        LoopMode.one => RepeatMode.one,
      };

  Future<AudioSource> _toAudioSource(Song song) async {
    final artFile = await artworkCache.fileForAlbum(song.albumId);
    return AudioSource.uri(
      Uri.file(song.data),
      tag: MediaItem(
        id: song.data,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        artUri: artFile != null ? Uri.file(artFile.path) : null,
      ),
    );
  }

  Future<void> playQueue(
    List<Song> songs, {
    int startIndex = 0,
    String? sourceLabel,
    bool shuffle = false,
  }) async {
    _queue = List.of(songs);
    _queueSourceLabel = sourceLabel;
    final children = await Future.wait(songs.map(_toAudioSource));
    await player.setShuffleModeEnabled(shuffle);
    await player.setAudioSources(children, initialIndex: startIndex);
    _hasQueue = true;
    if (shuffle) await player.shuffle();
    await player.play();
    notifyListeners();
  }

  Future<void> playSingle(Song song, {String? sourceLabel}) =>
      playQueue([song], sourceLabel: sourceLabel);

  Future<void> addToQueue(Song song) async {
    if (!_hasQueue) {
      await playQueue([song]);
      return;
    }
    _queue.add(song);
    await player.addAudioSource(await _toAudioSource(song));
    notifyListeners();
  }

  Future<void> playNext(Song song) async {
    if (!_hasQueue) {
      await playQueue([song]);
      return;
    }
    final insertAt = (currentIndex ?? 0) + 1;
    _queue.insert(insertAt, song);
    await player.insertAudioSource(insertAt, await _toAudioSource(song));
    notifyListeners();
  }

  Future<void> removeFromQueueAt(int index) async {
    if (!_hasQueue || index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    await player.removeAudioSourceAt(index);
    notifyListeners();
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (!_hasQueue) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    final song = _queue.removeAt(oldIndex);
    _queue.insert(target, song);
    await player.moveAudioSource(oldIndex, target);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> seek(Duration position) => player.seek(position);
  Future<void> jumpTo(int index) => player.seek(Duration.zero, index: index);
  Future<void> skipNext() => player.seekToNext();
  Future<void> skipPrevious() {
    if (player.position > const Duration(seconds: 3)) {
      return player.seek(Duration.zero);
    }
    return player.seekToPrevious();
  }

  Future<void> setShuffle(bool enabled) => player.setShuffleModeEnabled(enabled);

  Future<void> cycleRepeatMode() {
    final next = switch (repeatMode) {
      RepeatMode.off => LoopMode.all,
      RepeatMode.all => LoopMode.one,
      RepeatMode.one => LoopMode.off,
    };
    return player.setLoopMode(next);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
