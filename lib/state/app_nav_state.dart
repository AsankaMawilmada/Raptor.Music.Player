import 'package:flutter/foundation.dart';

/// Which top-level destination (Home/Favorites/Playlists/Tracks) is active
/// in the main navigation shell. Shared between HomeScreen's bottom nav and
/// the Now Playing screen's top nav so switching destinations works from
/// either place.
class AppNavState extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int value) {
    if (_index == value) return;
    _index = value;
    notifyListeners();
  }
}
