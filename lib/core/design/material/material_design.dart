import 'package:material_ui/material_ui.dart';

import '../../../domain/settings/appearance.dart';
import '../components/prism_address_field.dart';
import '../components/prism_button.dart';
import '../components/prism_controls.dart';
import '../components/prism_segmented.dart';
import '../components/prism_surface.dart';
import '../components/prism_tab_card.dart';
import '../components/prism_toolbar.dart';
import '../parts.dart';
import '../prism_design.dart';
import '../prism_icons.dart';
import '../theme_base.dart';
import '../tokens.dart';

/// Material 3 (Expressive): tonal surfaces, dynamic color, M3 shape scale.
/// Stage 6 adds shape morphing, spring motion and container transforms.
class MaterialDesign extends PrismDesign {
  const MaterialDesign();

  @override
  PrismStyleId get id => PrismStyleId.material;

  static PrismTokens tokensFor(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    return PrismTokens(
      canvas: s.surface,
      surface: s.surfaceContainer,
      surfaceRaised: s.surfaceContainerHigh,
      onSurface: s.onSurface,
      onSurfaceMuted: s.onSurfaceVariant,
      outline: s.outlineVariant,
      accent: s.primary,
      onAccent: s.onPrimary,
      accentSoft: s.secondaryContainer,
      secure: dark ? const Color(0xFF6DD58C) : const Color(0xFF146C2E),
      warning: dark ? const Color(0xFFFFB95C) : const Color(0xFF8A5100),
      danger: s.error,
      incognito: s.tertiary,
      scrim: s.scrim.withValues(alpha: 0.32),
      glassTint: Colors.transparent,
      glassBorderTop: Colors.transparent,
      glassBorderBottom: Colors.transparent,
      glassHighlight: Colors.transparent,
      // M3 shape scale: small 8, medium 12, large 16, extra-large 28.
      radiusSm: 8,
      radiusMd: 12,
      radiusLg: 16,
      radiusXl: 28,
      blurSigma: 0,
      shadowOpacity: 0,
    );
  }

  @override
  ThemeData buildTheme(PrismThemeInput input) {
    final scheme = ColorScheme.fromSeed(
      seedColor: input.seed,
      brightness: input.brightness,
    );
    final t = tokensFor(scheme);
    final base = buildBaseTheme(
      scheme: scheme,
      tokens: t,
      density: input.density,
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusXl)),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusLg),
        ),
      ),
    );
  }

  BorderRadius _radius(PrismTokens t, PrismSurfaceKind kind) => switch (kind) {
    PrismSurfaceKind.bar => BorderRadius.circular(t.radiusXl),
    PrismSurfaceKind.panel => BorderRadius.circular(t.radiusXl),
    PrismSurfaceKind.card => BorderRadius.circular(t.radiusLg),
    PrismSurfaceKind.menu => BorderRadius.circular(t.radiusSm),
    PrismSurfaceKind.island => BorderRadius.zero,
    PrismSurfaceKind.chrome => BorderRadius.zero,
  };

  @override
  Widget buildSurface(BuildContext context, PrismSurface s) {
    final t = PrismTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    // M3: groups inside a docked bar carry no container of their own.
    if (s.kind == PrismSurfaceKind.island) {
      return Padding(padding: s.padding, child: s.child);
    }
    final color = switch (s.kind) {
      PrismSurfaceKind.bar => scheme.surfaceContainer,
      PrismSurfaceKind.panel => scheme.surfaceContainerLow,
      PrismSurfaceKind.card => scheme.surfaceContainerHigh,
      PrismSurfaceKind.menu => scheme.surfaceContainer,
      PrismSurfaceKind.chrome => scheme.surfaceContainer,
      PrismSurfaceKind.island => Colors.transparent,
    };
    final radius = s.borderRadius ?? _radius(t, s.kind);
    return Material(
      color: s.selected ? scheme.secondaryContainer : color,
      elevation: s.kind == PrismSurfaceKind.menu ? 3 : 0,
      shadowColor: scheme.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: s.selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: s.padding, child: s.child),
    );
  }

  @override
  Widget buildToolbar(BuildContext context, PrismToolbar bar) {
    final scheme = Theme.of(context).colorScheme;
    final top = bar.position == PrismToolbarPosition.top;
    final density = densityOf(context);
    // Docked tonal bar, full width (M3 top app bar / bottom app bar).
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: top && bar.safeArea,
        bottom: !top && bar.safeArea,
        child: SizedBox(
          height: density.barHeight + PrismSpace.sm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
            child: Row(
              children: [
                ...bar.leading,
                Expanded(child: bar.middle),
                ...bar.trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildAddressField(BuildContext context, PrismAddressField f) {
    final t = PrismTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final empty = f.text.isEmpty;
    return Semantics(
      button: true,
      label: empty ? f.hint : f.text,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
        child: Material(
          color: scheme.surfaceContainerHighest,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: f.onTap,
            child: SizedBox(
              height: PrismSpace.touch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PrismSpace.lg),
                child: Row(
                  children: [
                    SecurityIcon(security: f.security, label: f.securityLabel),
                    const SizedBox(width: PrismSpace.md),
                    Expanded(
                      child: Text(
                        empty ? f.hint : f.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          color: empty ? t.onSurfaceMuted : t.onSurface,
                        ),
                      ),
                    ),
                    if (f.trailing != null) f.trailing!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTabCard(BuildContext context, PrismTabCard c) {
    final t = PrismTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(t.radiusLg);
    return Semantics(
      selected: c.selected,
      button: true,
      label: c.title,
      child: Material(
        color: c.selected
            ? scheme.secondaryContainer
            : (c.incognito
                  ? scheme.tertiaryContainer
                  : scheme.surfaceContainerHigh),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: c.selected
              ? BorderSide(color: scheme.primary, width: 3)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: c.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: PrismSpace.touch,
                child: Row(
                  children: [
                    const SizedBox(width: PrismSpace.md),
                    FaviconSlot(child: c.favicon),
                    const SizedBox(width: PrismSpace.sm),
                    if (c.pinned) ...[
                      Icon(PrismIcons.pinFilled, size: 14, color: t.accent),
                      const SizedBox(width: PrismSpace.xs),
                    ],
                    Expanded(
                      child: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                    ),
                    if (c.onClose != null)
                      PrismIconButton(
                        icon: PrismIcons.close,
                        tooltip: c.closeTooltip,
                        onPressed: c.onClose,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PrismSpace.xs,
                    0,
                    PrismSpace.xs,
                    PrismSpace.xs,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(t.radiusMd),
                    child: c.thumbnail ?? ThumbPlaceholder(host: c.host),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildButton(BuildContext context, PrismButton b) {
    final t = PrismTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final base = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(64, PrismSpace.touch)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: PrismSpace.xl),
      ),
      side: focusRing(t),
    );
    final icon = b.icon == null ? null : Icon(b.icon, size: 18);
    final label = Text(b.label);
    final Widget button = switch (b.variant) {
      PrismButtonVariant.primary =>
        icon == null
            ? FilledButton(onPressed: b.onPressed, style: base, child: label)
            : FilledButton.icon(
                onPressed: b.onPressed,
                style: base,
                icon: icon,
                label: label,
              ),
      PrismButtonVariant.secondary =>
        icon == null
            ? OutlinedButton(
                onPressed: b.onPressed,
                style: base.copyWith(
                  side: focusRing(t, idle: BorderSide(color: scheme.outline)),
                ),
                child: label,
              )
            : OutlinedButton.icon(
                onPressed: b.onPressed,
                style: base.copyWith(
                  side: focusRing(t, idle: BorderSide(color: scheme.outline)),
                ),
                icon: icon,
                label: label,
              ),
      PrismButtonVariant.ghost =>
        icon == null
            ? TextButton(onPressed: b.onPressed, style: base, child: label)
            : TextButton.icon(
                onPressed: b.onPressed,
                style: base,
                icon: icon,
                label: label,
              ),
      PrismButtonVariant.danger =>
        icon == null
            ? FilledButton.tonal(
                onPressed: b.onPressed,
                style: base.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    scheme.errorContainer,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    scheme.onErrorContainer,
                  ),
                ),
                child: label,
              )
            : FilledButton.tonalIcon(
                onPressed: b.onPressed,
                style: base.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    scheme.errorContainer,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    scheme.onErrorContainer,
                  ),
                ),
                icon: icon,
                label: label,
              ),
    };
    return b.expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  @override
  Widget buildIconButton(BuildContext context, PrismIconButton b) {
    final t = PrismTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: b.onPressed,
      tooltip: b.tooltip,
      isSelected: b.selected,
      icon: Icon(b.icon),
      selectedIcon: Icon(b.selectedIcon ?? b.icon),
      constraints: const BoxConstraints.tightFor(
        width: PrismSpace.touch,
        height: PrismSpace.touch,
      ),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? scheme.onSurface.withValues(alpha: 0.38)
              : s.contains(WidgetState.selected)
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.secondaryContainer
              : null,
        ),
        side: focusRing(t),
      ),
    );
  }

  @override
  Widget buildSegmented<T>(BuildContext context, PrismSegmented<T> c) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        segments: [
          for (final s in c.segments)
            ButtonSegment<T>(
              value: s.value,
              label: Text(s.label, maxLines: 1),
              icon: s.icon == null ? null : Icon(s.icon),
            ),
        ],
        selected: {c.selected},
        onSelectionChanged: (v) => c.onChanged(v.first),
      ),
    );
  }

  @override
  Widget buildBackground(BuildContext context) =>
      ColoredBox(color: PrismTokens.of(context).canvas);

  @override
  Widget buildIconBadge(BuildContext context, PrismIconBadge b) {
    final scheme = Theme.of(context).colorScheme;
    final t = PrismTokens.of(context);
    final (Color bg, Color fg) = switch (b.tone) {
      PrismBadgeTone.accent => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      PrismBadgeTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      PrismBadgeTone.danger => (scheme.errorContainer, scheme.onErrorContainer),
      PrismBadgeTone.secure || PrismBadgeTone.warning => (
        badgeColor(t, b.tone).withValues(alpha: 0.16),
        badgeColor(t, b.tone),
      ),
    };
    return Container(
      width: b.size,
      height: b.size,
      decoration: BoxDecoration(
        color: bg,
        // M3 Expressive: softer "squircle"-ish container shape.
        borderRadius: BorderRadius.circular(b.size * 0.36),
      ),
      child: Icon(b.icon, size: b.size * 0.5, color: fg),
    );
  }

  @override
  Widget buildChip(BuildContext context, PrismChip c) {
    return FilterChip(
      label: Text(c.label),
      selected: c.selected,
      onSelected: c.onTap == null ? null : (_) => c.onTap!(),
      avatar: c.color != null
          ? CircleAvatar(backgroundColor: c.color, radius: 5)
          : (c.icon != null && !c.selected ? Icon(c.icon, size: 18) : null),
      showCheckmark: true,
    );
  }

  @override
  Widget buildSearchField(BuildContext context, PrismSearchField f) {
    // SearchBar's tap target has no name of its own; give it the hint.
    return Semantics(label: f.hint, textField: true, child: _searchBar(f));
  }

  Widget _searchBar(PrismSearchField f) {
    return SearchBar(
      controller: f.controller,
      focusNode: f.focusNode,
      autoFocus: f.autofocus,
      hintText: f.hint,
      onChanged: f.onChanged,
      onSubmitted: f.onSubmitted,
      keyboardType: f.keyboardType,
      textInputAction: TextInputAction.go,
      elevation: const WidgetStatePropertyAll(0),
      constraints: const BoxConstraints(minHeight: 52),
      leading: Padding(
        padding: const EdgeInsets.only(left: PrismSpace.xs),
        child: Icon(f.leading ?? PrismIcons.search),
      ),
      trailing: [?f.trailing],
    );
  }

  @override
  Future<T?> showSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PrismSpace.xl,
          0,
          PrismSpace.xl,
          PrismSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: PrismSpace.md),
            ],
            Flexible(child: builder(ctx)),
          ],
        ),
      ),
    );
  }
}
