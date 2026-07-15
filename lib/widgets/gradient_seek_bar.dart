import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Seek bar matching the Lumina Audio design system's progress bar: a
/// rounded gradient-filled track with a handle that only appears while
/// dragging. [value] and the callbacks are normalized to 0..1; callers
/// convert to/from playback [Duration]s.
class GradientSeekBar extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double trackHeight;
  final bool showHandle;

  const GradientSeekBar({
    super.key,
    required this.value,
    this.onChanged,
    this.trackHeight = 6,
    this.showHandle = true,
  });

  @override
  State<GradientSeekBar> createState() => _GradientSeekBarState();
}

class _GradientSeekBarState extends State<GradientSeekBar> {
  bool _dragging = false;
  double? _dragValue;

  double get _value => (_dragValue ?? widget.value).clamp(0.0, 1.0);

  void _updateFromLocalX(double localX, double width) {
    if (width <= 0) return;
    final v = (localX / width).clamp(0.0, 1.0);
    setState(() => _dragValue = v);
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final handleSize = widget.trackHeight == 6 ? 12.0 : 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onChanged == null
              ? null
              : (details) => _updateFromLocalX(details.localPosition.dx, width),
          onHorizontalDragStart: widget.onChanged == null
              ? null
              : (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: widget.onChanged == null
              ? null
              : (details) => _updateFromLocalX(details.localPosition.dx, width),
          onHorizontalDragEnd: widget.onChanged == null
              ? null
              : (_) => setState(() {
                    _dragging = false;
                    _dragValue = null;
                  }),
          child: SizedBox(
            height: (widget.showHandle ? handleSize : widget.trackHeight) + 8,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: widget.trackHeight,
                    width: width,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: _value,
                    child: Container(
                      height: widget.trackHeight,
                      decoration: BoxDecoration(
                        gradient: AppGradients.vibrant,
                        borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                      ),
                    ),
                  ),
                  if (widget.showHandle)
                    Positioned(
                      left: (width * _value - handleSize / 2).clamp(0.0, width - handleSize),
                      child: AnimatedOpacity(
                        opacity: _dragging ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          width: handleSize,
                          height: handleSize,
                          decoration: BoxDecoration(
                            color: AppColors.vibrantGradientEnd,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
