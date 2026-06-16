import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Border radii used across the design system (matches --r-sm/--r/--r-lg/--r-xl).
class GriloRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 18.0;
  static const xl = 26.0;
}

class AppTheme {
  static ThemeData _build(Brightness brightness, GriloColors c) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.hankenGroteskTextTheme(base.textTheme).apply(
      bodyColor: c.tx,
      displayColor: c.tx,
    );
    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: c.accent,
        onPrimary: Colors.white,
        surface: c.surface,
        onSurface: c.tx,
        error: c.bad,
      ),
      textTheme: textTheme,
      extensions: [c],
      dividerColor: c.line,
      iconTheme: IconThemeData(color: c.tx2),
    );
  }

  static ThemeData get dark => _build(Brightness.dark, GriloColors.dark);
  static ThemeData get light => _build(Brightness.light, GriloColors.light);
}

extension BuildContextGrilo on BuildContext {
  GriloColors get gc => Theme.of(this).extension<GriloColors>()!;
}
