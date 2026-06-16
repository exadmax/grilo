import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

InputBorder _border(GriloColors c, {Color? color, double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(GriloRadius.md),
      borderSide: BorderSide(color: color ?? c.line2, width: width),
    );

/// `.field .input` — single-line text input.
class GriloTextField extends StatelessWidget {
  const GriloTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: c.tx),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: c.surface2,
        hintText: placeholder,
        hintStyle: TextStyle(color: c.tx3, fontSize: 14),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 16, color: c.tx3),
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 0),
        contentPadding: maxLines > 1
            ? const EdgeInsets.symmetric(horizontal: 13, vertical: 11)
            : const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        border: _border(c),
        enabledBorder: _border(c),
        focusedBorder: _border(c, color: c.accent, width: 2),
      ),
    );
  }
}

/// `select.input` — dropdown matching the prototype's native `<select>`.
class GriloDropdown<T> extends StatelessWidget {
  const GriloDropdown({super.key, required this.value, required this.items, required this.onChanged});

  final T value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: c.surface2,
        border: Border.all(color: c.line2),
        borderRadius: BorderRadius.circular(GriloRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.expand_more, size: 18, color: c.tx3),
          dropdownColor: c.surface,
          style: TextStyle(fontSize: 14, color: c.tx),
          borderRadius: BorderRadius.circular(GriloRadius.md),
          items: [for (final it in items) DropdownMenuItem(value: it.$1, child: Text(it.$2))],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// `.input-affix .input.tnum` — numeric stepper field with optional
/// prefix/suffix labels (e.g. "R$" / "kg").
class NumField extends StatefulWidget {
  const NumField({
    super.key,
    required this.value,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.placeholder,
    this.decimals = 2,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? prefix;
  final String? suffix;
  final String? placeholder;
  final int decimals;

  @override
  State<NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<NumField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.value));
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  String _format(double v) {
    var s = v.toStringAsFixed(widget.decimals);
    if (s.contains('.')) {
      while (s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    return s;
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      _ctrl.text = _format(widget.value);
    }
  }

  @override
  void didUpdateWidget(covariant NumField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.value != widget.value) {
      _ctrl.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit(String text) {
    final v = double.tryParse(text.replaceAll(',', '.'));
    widget.onChanged(v ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return TextField(
      controller: _ctrl,
      focusNode: _focus,
      onChanged: _commit,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      style: TextStyle(fontSize: 14, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()]),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: c.surface2,
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: c.tx3, fontSize: 14),
        prefixText: widget.prefix == null ? null : '${widget.prefix} ',
        suffixText: widget.suffix,
        prefixStyle: TextStyle(color: c.tx3, fontSize: 13),
        suffixStyle: TextStyle(color: c.tx3, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        border: _border(c),
        enabledBorder: _border(c),
        focusedBorder: _border(c, color: c.accent, width: 2),
      ),
    );
  }
}

/// `.switch` — pill toggle, accent-filled when on.
class GriloSwitch extends StatelessWidget {
  const GriloSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? c.accent : c.track,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 3, offset: const Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.range` — accent-thumbed slider used for risco/markup percentages.
class GriloSlider extends StatelessWidget {
  const GriloSlider({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 100, this.divisions});

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.track,
        thumbColor: c.accent,
        overlayColor: c.accent.withValues(alpha: .15),
        trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 1),
      ),
      child: Slider(value: value, onChanged: onChanged, min: min, max: max, divisions: divisions),
    );
  }
}
