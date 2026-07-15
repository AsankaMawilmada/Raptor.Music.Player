import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass surface used for the mini-player and bottom nav bar:
/// a blurred, translucent backdrop with a subtle light border, per the
/// Lumina Audio design system's "glass-player" component.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tint = brightness == Brightness.dark
        ? const Color(0xB32E3132)
        : const Color(0xB3FFFFFF);
    final borderColor =
        brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
