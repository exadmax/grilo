import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// `Donut` — SVG-style arc donut chart with an optional centered
/// label/value pair.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.data,
    this.size = 188,
    this.thickness = 26,
    this.centerLabel,
    this.centerValue,
  });

  /// (label, value, color) — `label` is unused visually but kept for parity
  /// with the legend that's rendered alongside the chart.
  final List<(String, double, Color)> data;
  final double size;
  final double thickness;
  final String? centerLabel;
  final String? centerValue;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(data: data, thickness: thickness, trackColor: c.track),
        child: centerValue == null
            ? null
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (centerLabel != null)
                      Text(
                        centerLabel!.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.tx3, letterSpacing: .66),
                      ),
                    const SizedBox(height: 4),
                    Text(centerValue!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.tx)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.data, required this.thickness, required this.trackColor});

  final List<(String, double, Color)> data;
  final double thickness;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.shortestSide - thickness) / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );

    final total = data.fold<double>(0, (a, d) => a + d.$2);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final d in data) {
      if (d.$2 <= 0) continue;
      final sweep = (d.$2 / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = d.$3
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.thickness != thickness || oldDelegate.trackColor != trackColor;
}

/// `.bd-bar` — proportional stacked bar showing the cost breakdown.
class BreakdownBar extends StatelessWidget {
  const BreakdownBar({super.key, required this.data});

  /// (label, value, color)
  final List<(String, double, Color)> data;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final segments = data.where((d) => d.$2 > 0).toList();
    final total = segments.fold<double>(0, (a, d) => a + d.$2);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 10,
        color: c.surface2,
        child: total <= 0
            ? null
            : Row(
                children: [
                  for (final d in segments)
                    Expanded(
                      flex: (d.$2 / total * 1000).round().clamp(1, 1000000),
                      child: Container(color: d.$3),
                    ),
                ],
              ),
      ),
    );
  }
}

/// `.legend` — vertical legend rows shown next to a [DonutChart].
class DonutLegend extends StatelessWidget {
  const DonutLegend({super.key, required this.data, required this.format});

  /// (label, value, color)
  final List<(String, double, Color)> data;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final segments = data.where((d) => d.$2 > 0).toList();
    final total = segments.fold<double>(0, (a, d) => a + d.$2) == 0 ? 1.0 : segments.fold<double>(0, (a, d) => a + d.$2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in segments)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: d.$3, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 10),
                Expanded(child: Text(d.$1, style: TextStyle(fontSize: 13.5, color: c.tx2))),
                Text(format(d.$2), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${(d.$2 / total * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: c.tx3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
