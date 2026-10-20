import 'package:material_ui/material_ui.dart';

import '../prism_icons.dart';
import '../tokens.dart';
import 'prism_controls.dart';
import 'prism_surface.dart';

/// List row used by settings, library and menus. Style-agnostic: it only
/// composes Prism primitives and tokens, so it adapts to every style.
class PrismTile extends StatelessWidget {
  const PrismTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tone = PrismBadgeTone.accent,
    this.leading,
    this.trailing,
    this.onTap,
    this.limitedLabel,
    this.chevron = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final PrismBadgeTone tone;

  /// Overrides the icon badge (favicons, progress rings).
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Honest platform limitation marker ("Limited on Android"), shown as a
  /// warning pill under the title. Never fake a working feature.
  final String? limitedLabel;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final lead =
        leading ??
        (icon == null ? null : PrismIconBadge(icon: icon!, tone: tone));
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PrismSpace.lg,
              vertical: PrismSpace.md,
            ),
            child: Row(
              children: [
                if (lead != null) ...[lead, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: text.bodyMedium?.copyWith(
                            color: t.onSurfaceMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (limitedLabel != null) ...[
                        const SizedBox(height: PrismSpace.xs + 2),
                        _LimitedPill(label: limitedLabel!),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: PrismSpace.md),
                  trailing!,
                ],
                if (chevron) ...[
                  const SizedBox(width: PrismSpace.sm),
                  Icon(
                    PrismIcons.chevronRight,
                    size: 18,
                    color: t.onSurfaceMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LimitedPill extends StatelessWidget {
  const _LimitedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpace.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PrismIcons.info, size: 14, color: t.warning),
          const SizedBox(width: PrismSpace.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: t.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile with a trailing switch; the whole row toggles.
class PrismSwitchTile extends StatelessWidget {
  const PrismSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tone = PrismBadgeTone.accent,
    required this.value,
    required this.onChanged,
    this.limitedLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final PrismBadgeTone tone;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? limitedLabel;

  @override
  Widget build(BuildContext context) => PrismTile(
    title: title,
    subtitle: subtitle,
    icon: icon,
    tone: tone,
    limitedLabel: limitedLabel,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

/// Friendly empty state: icon, title, one line of guidance.
class PrismEmptyState extends StatelessWidget {
  const PrismEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpace.xl,
        vertical: PrismSpace.xxxl,
      ),
      child: Column(
        children: [
          PrismIconBadge(icon: icon, tone: PrismBadgeTone.neutral, size: 64),
          const SizedBox(height: PrismSpace.lg),
          Text(title, style: text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: PrismSpace.sm),
          Text(body, style: text.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Titled group of tiles on one card surface, separated by hairlines.
class PrismSection extends StatelessWidget {
  const PrismSection({
    super.key,
    this.title,
    required this.children,
    this.footer,
  });

  final String? title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PrismSpace.xs,
                0,
                PrismSpace.xs,
                PrismSpace.sm,
              ),
              child: Semantics(
                header: true,
                child: Text(title!.toUpperCase(), style: text.labelSmall),
              ),
            ),
          PrismSurface(
            kind: PrismSurfaceKind.card,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 70,
                      endIndent: PrismSpace.lg,
                      color: t.outline,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PrismSpace.xs,
                PrismSpace.sm,
                PrismSpace.xs,
                0,
              ),
              child: Text(footer!, style: text.bodySmall),
            ),
        ],
      ),
    );
  }
}
