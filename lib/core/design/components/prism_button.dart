import 'package:flutter/widgets.dart';

import '../prism_design.dart';

enum PrismButtonVariant {
  /// One per screen: the main action.
  primary,
  secondary,

  /// Low emphasis, text-only.
  ghost,

  /// Destructive actions ("Forget everything").
  danger,
}

class PrismButton extends StatelessWidget {
  const PrismButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = PrismButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PrismButtonVariant variant;

  /// Stretch to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildButton(context, this);
}

/// Icon-only button. [tooltip] is mandatory: it is the accessible name for
/// TalkBack / Narrator and the hover tooltip on desktop.
class PrismIconButton extends StatelessWidget {
  const PrismIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.selected = false,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildIconButton(context, this);
}
