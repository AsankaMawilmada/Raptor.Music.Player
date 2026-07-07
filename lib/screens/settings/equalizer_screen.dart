import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:provider/provider.dart';

import '../../state/player_state.dart';

/// Gains in dB per band for a handful of Samsung-Music-style presets. Actual
/// band count/frequencies come from the device's Android equalizer, so
/// presets are applied proportionally across however many bands exist.
const Map<String, List<double>> _presets = {
  'Normal': [0, 0, 0, 0, 0],
  'Pop': [-1, 2, 4, 2, -1],
  'Rock': [4, 2, -2, 2, 4],
  'Jazz': [3, 1, 0, 2, 3],
  'Classical': [4, 3, 0, 2, 3],
  'Dance': [5, 3, 0, 1, 4],
  'Bass boost': [6, 4, 0, 0, 0],
  'Treble boost': [0, 0, 0, 4, 6],
};

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  AndroidEqualizerParameters? _params;
  String _preset = 'Normal';
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    final playerState = context.read<PlayerState>();
    _enabled = playerState.equalizer.enabled;
    playerState.equalizer.parameters.then((params) {
      if (mounted) setState(() => _params = params);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = context.read<PlayerState>();
    final params = _params;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        actions: [
          Switch(
            value: _enabled,
            onChanged: (value) async {
              await playerState.equalizer.setEnabled(value);
              setState(() => _enabled = value);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: params == null
          ? const Center(child: CircularProgressIndicator())
          : AbsorbPointer(
              absorbing: !_enabled,
              child: Opacity(
                opacity: _enabled ? 1 : 0.4,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        children: _presets.keys
                            .map((name) => ChoiceChip(
                                  label: Text(name),
                                  selected: _preset == name,
                                  onSelected: (_) => _applyPreset(name, params),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final band in params.bands)
                            _BandSlider(
                              band: band,
                              min: params.minDecibels,
                              max: params.maxDecibels,
                              onChanged: () => setState(() => _preset = 'Custom'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _applyPreset(String name, AndroidEqualizerParameters params) async {
    final gains = _presets[name];
    if (gains == null) return;
    for (var i = 0; i < params.bands.length; i++) {
      final gain = gains[i % gains.length].clamp(params.minDecibels, params.maxDecibels);
      await params.bands[i].setGain(gain.toDouble());
    }
    setState(() => _preset = name);
  }
}

class _BandSlider extends StatefulWidget {
  final AndroidEqualizerBand band;
  final double min;
  final double max;
  final VoidCallback onChanged;

  const _BandSlider({required this.band, required this.min, required this.max, required this.onChanged});

  @override
  State<_BandSlider> createState() => _BandSliderState();
}

class _BandSliderState extends State<_BandSlider> {
  @override
  Widget build(BuildContext context) {
    final freq = widget.band.centerFrequency;
    final label = freq >= 1000 ? '${(freq / 1000).toStringAsFixed(freq >= 10000 ? 0 : 1)}k' : freq.toStringAsFixed(0);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<double>(
            stream: widget.band.gainStream,
            initialData: widget.band.gain,
            builder: (context, snapshot) {
              return RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: (snapshot.data ?? 0).clamp(widget.min, widget.max),
                  min: widget.min,
                  max: widget.max,
                  onChanged: (value) {
                    widget.band.setGain(value);
                    widget.onChanged();
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('${label}Hz', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
