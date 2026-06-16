import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// `.card` — surface container with border, radius and soft shadow.
class GriloCard extends StatelessWidget {
  const GriloCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(GriloRadius.lg),
        boxShadow: c.shadow,
      ),
      child: child,
    );
  }
}

/// `.card-pad` padding constant (22px 24px).
const griloCardPad = EdgeInsets.fromLTRB(24, 22, 24, 22);

/// `.card-h` — icon + title row with a bottom border, used as a card header.
class CardHeader extends StatelessWidget {
  const CardHeader({super.key, required this.icon, required this.title, this.trailing});
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(GriloRadius.md)),
            child: Icon(icon, size: 18, color: c.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// `.field` — labeled form field wrapper with optional hint text.
class FieldWrapper extends StatelessWidget {
  const FieldWrapper({super.key, required this.label, this.hint, this.trailing, required this.child});
  final String label;
  final String? hint;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tx2)),
            ?trailing,
          ],
        ),
        const SizedBox(height: 7),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: TextStyle(fontSize: 11.5, color: c.tx3)),
        ],
      ],
    );
  }
}

/// `.toggle-row` — icon/switch + meta text row on a soft surface.
class ToggleRow extends StatelessWidget {
  const ToggleRow({super.key, required this.leading, required this.title, this.subtitle, this.trailing, this.accentBg = false});
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool accentBg;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accentBg ? c.accentSoft : c.surface2,
        border: accentBg ? null : Border.all(color: c.line),
        borderRadius: BorderRadius.circular(GriloRadius.md),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: TextStyle(fontSize: 12, color: c.tx2)),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// `.seg` — segmented control with a small leading widget + label per option.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({super.key, required this.value, required this.options, required this.onChanged, this.compact = false});
  final T value;
  final List<(T id, String label, Widget Function(bool on)? leading)> options;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(GriloRadius.md),
      ),
      child: Wrap(
        children: options.map((o) {
          final on = o.$1 == value;
          return Padding(
            padding: const EdgeInsets.all(0),
            child: Material(
              color: on ? c.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(o.$1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 10, vertical: compact ? 9 : 11),
                  decoration: on
                      ? BoxDecoration(borderRadius: BorderRadius.circular(9), boxShadow: c.shadow)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (o.$3 != null) ...[
                        o.$3!(on),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        o.$2,
                        style: TextStyle(
                          fontSize: compact ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: on ? c.tx : c.tx2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// `.chip` — small pill badge.
class GriloChip extends StatelessWidget {
  const GriloChip({super.key, this.leading, this.label, this.bg, this.fg, this.borderColor, this.onTap});
  final Widget? leading;
  final String? label;
  final Color? bg;
  final Color? fg;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? c.chip,
        border: Border.all(color: borderColor ?? c.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          if (label != null)
            Text(label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg ?? c.tx2)),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(999), onTap: onTap, child: content);
  }
}

/// `.empty` — empty-state placeholder for tables.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(GriloRadius.lg)),
            child: Icon(icon, color: c.tx3, size: 26),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: c.tx3)),
        ],
      ),
    );
  }
}
