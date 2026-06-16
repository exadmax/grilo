import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// `.chip` with an `.engine-dot` — identifies print3d vs croche.
class EngineBadge extends StatelessWidget {
  const EngineBadge({super.key, required this.engine, this.withLabel = true});

  final CraftEngineId engine;
  final bool withLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.chip,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: engine.dotColor, borderRadius: BorderRadius.circular(3)),
          ),
          if (withLabel) ...[
            const SizedBox(width: 6),
            Text(engine.nome, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.tx2)),
          ],
        ],
      ),
    );
  }
}

/// `.chip` colored by ANEEL tariff flag ("Bandeira").
class BandeiraBadge extends StatelessWidget {
  const BandeiraBadge({super.key, required this.bandeira, this.withLabel = true});

  final Bandeira bandeira;
  final bool withLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bandeira.color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: bandeira.color, shape: BoxShape.circle),
          ),
          if (withLabel) ...[
            const SizedBox(width: 6),
            Text('Bandeira ${bandeira.label}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: bandeira.color)),
          ],
        ],
      ),
    );
  }
}

/// `.stat` — KPI tile with icon label, big value and optional delta.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value, this.delta, this.deltaUp = false});

  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final bool deltaUp;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(GriloRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: c.tx2),
              const SizedBox(width: 7),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.tx2)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.02 * 28),
          ),
          if (delta != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(delta!, style: TextStyle(fontSize: 12, color: deltaUp ? c.good : c.tx3)),
            ),
        ],
      ),
    );
  }
}

/// Small swatch used inside material pickers (`.mat-swatch`).
class MaterialSwatch extends StatelessWidget {
  const MaterialSwatch({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(GriloRadius.md),
      ),
      child: Icon(Icons.layers_outlined, size: 18, color: c.accent),
    );
  }
}
