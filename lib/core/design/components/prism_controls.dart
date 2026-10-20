import 'package:flutter/widgets.dart';

import '../prism_design.dart';

/// Screen background. Glass: the Prism light wallpaper (something for the
/// glass to refract). Material: the flat M3 surface.
class PrismBackground extends StatelessWidget {
  const PrismBackground({super.key});

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildBackground(context);
}

enum PrismBadgeTone { accent, secure, warning, danger, neutral }

/// Rounded-square icon tile at the start of list rows (settings, menus).
class PrismIconBadge extends StatelessWidget {
  const PrismIconBadge({
    super.key,
    required this.icon,
    this.tone = PrismBadgeTone.accent,
    this.size = 40,
  });

  final IconData icon;
  final PrismBadgeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildIconBadge(context, this);
}

/// Filter / choice chip.
class PrismChip extends StatelessWidget {
  const PrismChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.color,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  /// Optional identity color (tab group dot).
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildChip(context, this);
}

/// Editable search / omnibox field.
class PrismSearchField extends StatelessWidget {
  const PrismSearchField({
    super.key,
    this.controller,
    required this.hint,
    this.leading,
    this.trailing,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String hint;
  final IconData? leading;
  final Widget? trailing;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildSearchField(context, this);
}
