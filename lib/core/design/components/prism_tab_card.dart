import 'package:flutter/widgets.dart';

import '../prism_design.dart';

/// A tab in the tab switcher (grid/stack). The thumbnail is provided by the
/// caller (cached screenshot or placeholder) so cards stay cheap to build.
class PrismTabCard extends StatelessWidget {
  const PrismTabCard({
    super.key,
    required this.title,
    required this.host,
    this.thumbnail,
    this.favicon,
    this.selected = false,
    this.pinned = false,
    this.incognito = false,
    this.onTap,
    this.onClose,
    required this.closeTooltip,
  });

  final String title;
  final String host;
  final Widget? thumbnail;
  final Widget? favicon;
  final bool selected;
  final bool pinned;
  final bool incognito;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  /// Localized label for the close button (tooltip + screen readers).
  final String closeTooltip;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildTabCard(context, this);
}
