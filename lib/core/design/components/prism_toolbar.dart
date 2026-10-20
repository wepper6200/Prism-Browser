import 'package:flutter/widgets.dart';

import '../prism_design.dart';

/// Browser toolbar: leading actions, a flexible middle (usually the omnibox)
/// and trailing actions. Glass renders a floating capsule, Material a
/// docked tonal bar.
class PrismToolbar extends StatelessWidget {
  const PrismToolbar({
    super.key,
    this.leading = const [],
    required this.middle,
    this.trailing = const [],
    this.position = PrismToolbarPosition.top,
    this.safeArea = true,
  });

  final List<Widget> leading;
  final Widget middle;
  final List<Widget> trailing;
  final PrismToolbarPosition position;

  /// False for a bar stacked above another bar that already pads for the
  /// system inset (address bar above the bottom action bar).
  final bool safeArea;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildToolbar(context, this);
}

enum PrismToolbarPosition { top, bottom }
