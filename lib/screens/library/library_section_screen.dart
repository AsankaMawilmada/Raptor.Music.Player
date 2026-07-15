import 'package:flutter/material.dart';

/// Thin wrapper that gives a library tab (Albums/Artists/Folders) its own
/// standalone screen with an app bar, for when it's reached from a card
/// instead of living directly in the bottom nav.
class LibrarySectionScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const LibrarySectionScreen({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}
