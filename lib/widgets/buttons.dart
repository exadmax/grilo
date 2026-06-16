import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum GriloButtonVariant { normal, primary, ghost }

/// Generic button matching `.btn` / `.btn.pri` / `.btn.ghost`.
class GriloButton extends StatelessWidget {
  const GriloButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAfter = false,
    this.onPressed,
    this.variant = GriloButtonVariant.normal,
    this.expand = false,
    this.hideLabelOnNarrow = false,
  });

  final String label;
  final IconData? icon;
  final bool iconAfter;
  final VoidCallback? onPressed;
  final GriloButtonVariant variant;
  final bool expand;
  final bool hideLabelOnNarrow;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final disabled = onPressed == null;

    final text = Flexible(
      child: Text(
        label,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
    final iconWidget = icon == null ? null : Icon(icon, size: 17);

    Widget child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAfter
          ? [text, if (iconWidget != null) ...[const SizedBox(width: 8), iconWidget]]
          : [if (iconWidget != null) ...[iconWidget, const SizedBox(width: 8)], text],
    );

    BoxDecoration decoration;
    Color fg;
    switch (variant) {
      case GriloButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.accent, c.accent2],
          ),
          borderRadius: BorderRadius.circular(GriloRadius.md),
          boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .35), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -10)],
        );
        fg = Colors.white;
      case GriloButtonVariant.ghost:
        decoration = const BoxDecoration();
        fg = c.tx2;
      case GriloButtonVariant.normal:
        decoration = BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.line2),
          borderRadius: BorderRadius.circular(GriloRadius.md),
        );
        fg = c.tx;
    }

    return Opacity(
      opacity: disabled ? .4 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GriloRadius.md),
          child: Container(
            decoration: decoration,
            padding: EdgeInsets.symmetric(horizontal: variant == GriloButtonVariant.ghost ? 12 : 16, vertical: variant == GriloButtonVariant.ghost ? 9 : 10),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg),
              child: IconTheme.merge(data: IconThemeData(color: fg), child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square outline icon button matching `.icon-btn` (38x38).
class GriloIconButton extends StatelessWidget {
  const GriloIconButton({super.key, required this.icon, this.onPressed, this.size = 38});
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GriloRadius.md),
          side: BorderSide(color: c.line2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(GriloRadius.md),
          onTap: onPressed,
          child: Icon(icon, size: 20, color: c.tx2),
        ),
      ),
    );
  }
}

/// Small transparent action button used in table rows (`.mini-btn`).
class GriloMiniButton extends StatelessWidget {
  const GriloMiniButton({super.key, required this.icon, this.onPressed, this.danger = false});
  final IconData icon;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GriloRadius.sm)),
        child: InkWell(
          borderRadius: BorderRadius.circular(GriloRadius.sm),
          onTap: onPressed,
          hoverColor: c.chip,
          child: Icon(icon, size: 16, color: danger ? c.bad : c.tx3),
        ),
      ),
    );
  }
}
