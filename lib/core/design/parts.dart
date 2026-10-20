import 'package:material_ui/material_ui.dart';

import 'components/prism_address_field.dart';
import 'components/prism_controls.dart';
import 'prism_icons.dart';
import 'tokens.dart';

/// Small building blocks shared by all [PrismDesign] implementations.

class SecurityIcon extends StatelessWidget {
  const SecurityIcon({super.key, required this.security, this.label});

  final PrismSecurity security;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final (IconData icon, Color color) = switch (security) {
      PrismSecurity.secure => (PrismIcons.lock, t.secure),
      PrismSecurity.insecure => (PrismIcons.lockOpen, t.warning),
      PrismSecurity.internal => (PrismIcons.search, t.onSurfaceMuted),
    };
    return Icon(icon, size: 18, color: color, semanticLabel: label);
  }
}

class FaviconSlot extends StatelessWidget {
  const FaviconSlot({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return SizedBox.square(
      dimension: 20,
      child: child ?? Icon(PrismIcons.globe, size: 18, color: t.onSurfaceMuted),
    );
  }
}

class ThumbPlaceholder extends StatelessWidget {
  const ThumbPlaceholder({super.key, required this.host});

  final String host;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return ColoredBox(
      color: t.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PrismSpace.sm),
          child: Text(
            host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

/// Semantic color of an icon badge tone.
Color badgeColor(PrismTokens t, PrismBadgeTone tone) => switch (tone) {
  PrismBadgeTone.accent => t.accent,
  PrismBadgeTone.secure => t.secure,
  PrismBadgeTone.warning => t.warning,
  PrismBadgeTone.danger => t.danger,
  PrismBadgeTone.neutral => t.onSurfaceMuted,
};

/// Resolves bar heights from the theme's visual density (set from
/// [UiDensity] in `buildBaseTheme`).
PrismDensity densityOf(BuildContext context) =>
    Theme.of(context).visualDensity == VisualDensity.compact
    ? PrismDensity.compact
    : PrismDensity.comfortable;
