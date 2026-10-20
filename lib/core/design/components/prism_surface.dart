import 'package:flutter/widgets.dart';

import '../prism_design.dart';

enum PrismSurfaceKind {
  /// Floating toolbars (address bar, navigation bar).
  bar,

  /// Large containers: tab switcher, suggestions panel, side panels.
  panel,

  /// Content cards inside panels/screens.
  card,

  /// Popup menus, tooltips, context menus.
  menu,

  /// A group of related controls inside a toolbar (nav buttons, actions,
  /// tabs). Glass: its own floating capsule. Material: no decoration (the
  /// whole bar is one docked surface).
  island,

  /// Container of a whole toolbar area holding islands. Glass: transparent
  /// (islands float over the content). Material: the docked tonal bar.
  chrome,
}

/// Style-agnostic container. Glass renders a blurred, refracting material;
/// Material renders a tonal surface container.
class PrismSurface extends StatelessWidget {
  const PrismSurface({
    super.key,
    required this.child,
    this.kind = PrismSurfaceKind.panel,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.selected = false,
  });

  final Widget child;
  final PrismSurfaceKind kind;
  final EdgeInsetsGeometry padding;

  /// Overrides the style's default radius for [kind].
  final BorderRadius? borderRadius;
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildSurface(context, this);
}
