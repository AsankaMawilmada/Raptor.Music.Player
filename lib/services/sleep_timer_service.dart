import 'dart:async';

import 'package:flutter/foundation.dart';

enum SleepTimerMode { duration, endOfTrack }

/// Simple countdown timer that can either fire after a fixed duration or be
/// armed to fire once the current track finishes.
class SleepTimerService extends ChangeNotifier {
  Timer? _timer;
  Duration? _remaining;
  bool _endOfTrackArmed = false;
  VoidCallback? onFire;

  Duration? get remaining => _remaining;
  bool get isActive => _timer != null || _endOfTrackArmed;
  bool get endOfTrackArmed => _endOfTrackArmed;

  void startCountdown(Duration duration) {
    cancel();
    _remaining = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final r = _remaining;
      if (r == null) return;
      final next = r - const Duration(seconds: 1);
      if (next.isNegative || next == Duration.zero) {
        _fire();
      } else {
        _remaining = next;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void armEndOfTrack() {
    cancel();
    _endOfTrackArmed = true;
    notifyListeners();
  }

  /// Call when the current track finishes; fires the timer if end-of-track
  /// mode is armed.
  void notifyTrackEnded() {
    if (_endOfTrackArmed) _fire();
  }

  void _fire() {
    cancel();
    onFire?.call();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = null;
    _endOfTrackArmed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
