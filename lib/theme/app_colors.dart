import 'package:flutter/material.dart';

/// Semantic colors for the Grilo design system, mirroring the CSS custom
/// properties from the original prototype (styles.css).
@immutable
class GriloColors extends ThemeExtension<GriloColors> {
  const GriloColors({
    required this.bg,
    required this.bgGradCenter,
    required this.surface,
    required this.surface2,
    required this.elev,
    required this.line,
    required this.line2,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.accentTx,
    required this.good,
    required this.goodSoft,
    required this.warn,
    required this.warnSoft,
    required this.bad,
    required this.chip,
    required this.track,
    required this.shadow,
  });

  final Color bg;
  final Color bgGradCenter;
  final Color surface;
  final Color surface2;
  final Color elev;
  final Color line;
  final Color line2;
  final Color tx;
  final Color tx2;
  final Color tx3;
  final Color accent;
  final Color accent2;
  final Color accentSoft;
  final Color accentTx;
  final Color good;
  final Color goodSoft;
  final Color warn;
  final Color warnSoft;
  final Color bad;
  final Color chip;
  final Color track;
  final List<BoxShadow> shadow;

  static const accentColor = Color(0xFFE0633E);
  static const accent2Color = Color(0xFFE9855F);

  static final dark = GriloColors(
    bg: const Color(0xFF15171C),
    bgGradCenter: const Color(0xFF1C2733),
    surface: const Color(0xFF1C1F26),
    surface2: const Color(0xFF22262E),
    elev: const Color(0xFF272B34),
    line: Colors.white.withValues(alpha: .075),
    line2: Colors.white.withValues(alpha: .13),
    tx: const Color(0xFFF1EFE9),
    tx2: const Color(0xFFA5A39B),
    tx3: const Color(0xFF6E6D68),
    accent: accentColor,
    accent2: accent2Color,
    accentSoft: accentColor.withValues(alpha: .16),
    accentTx: const Color(0xFFF0A98E),
    good: const Color(0xFF4CC38A),
    goodSoft: const Color(0xFF4CC38A).withValues(alpha: .15),
    warn: const Color(0xFFE0A23E),
    warnSoft: const Color(0xFFE0A23E).withValues(alpha: .15),
    bad: const Color(0xFFE5573F),
    chip: Colors.white.withValues(alpha: .05),
    track: Colors.white.withValues(alpha: .09),
    shadow: [
      BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 40, offset: const Offset(0, 18), spreadRadius: -20),
    ],
  );

  static final light = GriloColors(
    bg: const Color(0xFFF4F1EA),
    bgGradCenter: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    surface2: const Color(0xFFFAF8F3),
    elev: const Color(0xFFFFFFFF),
    line: const Color(0xFF28241C).withValues(alpha: .09),
    line2: const Color(0xFF28241C).withValues(alpha: .16),
    tx: const Color(0xFF221F1A),
    tx2: const Color(0xFF6B675E),
    tx3: const Color(0xFF9A958A),
    accent: accentColor,
    accent2: accent2Color,
    accentSoft: accentColor.withValues(alpha: .12),
    accentTx: const Color(0xFFB84A27),
    good: const Color(0xFF1F9D63),
    goodSoft: const Color(0xFF1F9D63).withValues(alpha: .12),
    warn: const Color(0xFFB9821F),
    warnSoft: const Color(0xFFB9821F).withValues(alpha: .12),
    bad: const Color(0xFFE5573F),
    chip: const Color(0xFF28241C).withValues(alpha: .04),
    track: const Color(0xFF28241C).withValues(alpha: .1),
    shadow: [
      BoxShadow(color: const Color(0xFF28241C).withValues(alpha: .04), blurRadius: 2),
      BoxShadow(color: const Color(0xFF28241C).withValues(alpha: .25), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -18),
    ],
  );

  @override
  GriloColors copyWith({
    Color? bg,
    Color? bgGradCenter,
    Color? surface,
    Color? surface2,
    Color? elev,
    Color? line,
    Color? line2,
    Color? tx,
    Color? tx2,
    Color? tx3,
    Color? accent,
    Color? accent2,
    Color? accentSoft,
    Color? accentTx,
    Color? good,
    Color? goodSoft,
    Color? warn,
    Color? warnSoft,
    Color? bad,
    Color? chip,
    Color? track,
    List<BoxShadow>? shadow,
  }) {
    return GriloColors(
      bg: bg ?? this.bg,
      bgGradCenter: bgGradCenter ?? this.bgGradCenter,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      elev: elev ?? this.elev,
      line: line ?? this.line,
      line2: line2 ?? this.line2,
      tx: tx ?? this.tx,
      tx2: tx2 ?? this.tx2,
      tx3: tx3 ?? this.tx3,
      accent: accent ?? this.accent,
      accent2: accent2 ?? this.accent2,
      accentSoft: accentSoft ?? this.accentSoft,
      accentTx: accentTx ?? this.accentTx,
      good: good ?? this.good,
      goodSoft: goodSoft ?? this.goodSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      bad: bad ?? this.bad,
      chip: chip ?? this.chip,
      track: track ?? this.track,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  GriloColors lerp(ThemeExtension<GriloColors>? other, double t) {
    if (other is! GriloColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GriloColors(
      bg: c(bg, other.bg),
      bgGradCenter: c(bgGradCenter, other.bgGradCenter),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      elev: c(elev, other.elev),
      line: c(line, other.line),
      line2: c(line2, other.line2),
      tx: c(tx, other.tx),
      tx2: c(tx2, other.tx2),
      tx3: c(tx3, other.tx3),
      accent: c(accent, other.accent),
      accent2: c(accent2, other.accent2),
      accentSoft: c(accentSoft, other.accentSoft),
      accentTx: c(accentTx, other.accentTx),
      good: c(good, other.good),
      goodSoft: c(goodSoft, other.goodSoft),
      warn: c(warn, other.warn),
      warnSoft: c(warnSoft, other.warnSoft),
      bad: c(bad, other.bad),
      chip: c(chip, other.chip),
      track: c(track, other.track),
      shadow: t < .5 ? shadow : other.shadow,
    );
  }
}

/// Engine accent colors (used for chips/dots that mark print3d vs croche).
const dotPrint3d = Color(0xFF6AA9E0);
const dotCroche = Color(0xFFD68AB0);

/// Cost-breakdown category colors shared across engines.
const breakdownColors = <String, Color>{
  'Material': Color(0xFF6AA9E0),
  'Energia': Color(0xFFE0A23E),
  'Consumíveis': Color(0xFF7DD3C0),
  'Depreciação': Color(0xFFB08AE0),
  'Mão de obra': Color(0xFFE0633E),
  'Setup': Color(0xFF9AA0A8),
  'Risco': Color(0xFFE5573F),
  'Fios': Color(0xFFD68AB0),
  'Acessórios': Color(0xFF7DD3C0),
};
