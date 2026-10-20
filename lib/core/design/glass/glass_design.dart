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
import '../prism_backdrop.dart';
import '../prism_design.dart';
import '../prism_icons.dart';
import '../theme_base.dart';
import '../tokens.dart';
import 'glass_material.dart';
import 'glass_pill.dart';
import 'glass_segmented.dart';

/// Liquid Glass: translucent, blurred, floating chrome over edge-to-edge
/// content. Glass is used only for navigation and controls; content stays
/// on its own opaque layer for readability.
class GlassDesign extends PrismDesign {
  const GlassDesign();

  @override
  PrismStyleId get id => PrismStyleId.glass;

  static PrismTokens tokensFor(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return PrismTokens(
      canvas: dark ? const Color(0xFF0B1020) : const Color(0xFFEEF1F8),
      surface: dark ? const Color(0xFF161C2E) : const Color(0xFFFFFFFF),
      surfaceRaised: dark ? const Color(0xFF1E2538) : const Color(0xFFF6F7FB),
      onSurface: dark ? const Color(0xFFF4F6FB) : const Color(0xFF0E1322),
      onSurfaceMuted: dark ? const Color(0xFFA7B0C4) : const Color(0xFF4A5468),
      outline: dark ? const Color(0x1FFFFFFF) : const Color(0x1A0E1322),
      accent: scheme.primary,
      onAccent: scheme.onPrimary,
      accentSoft: scheme.primary.withValues(alpha: dark ? 0.22 : 0.14),
      secure: dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
      warning: dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
      danger: dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      incognito: dark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
      scrim: const Color(0x80000000),
      // Tint opacities chosen so muted text keeps >= 4.5:1 over any backdrop
      // (worst case checked in test/design/contrast_test.dart).
      glassTint: dark ? const Color(0xA6161C2E) : const Color(0xB3FFFFFF),
      glassBorderTop: dark ? const Color(0x47FFFFFF) : const Color(0xE6FFFFFF),
      glassBorderBottom: dark
          ? const Color(0x0FFFFFFF)
          : const Color(0x1A0E1322),
      glassHighlight: dark ? const Color(0x1FFFFFFF) : const Color(0x80FFFFFF),
      radiusSm: 12,
      radiusMd: 18,
      radiusLg: 26,
      radiusXl: 34,
      blurSigma: 22,
      shadowOpacity: dark ? 0.35 : 0.12,
    );
  }

  @override
  ThemeData buildTheme(PrismThemeInput input) {
    final scheme = ColorScheme.fromSeed(
      seedColor: input.seed,
      brightness: input.brightness,
    );
    final t = tokensFor(scheme);
    final dark = input.brightness == Brightness.dark;
    final base = buildBaseTheme(
      scheme: scheme.copyWith(surface: t.surface, onSurface: t.onSurface),
      tokens: t,
      density: input.density,
      splashFactory: InkRipple.splashFactory,
    );
    return base.copyWith(
      // Monochrome glass switch (user reference): off = recessed dark track
      // with a grey knob; on = bright clear glass (dark) / accent (light).
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(
          dark ? const Color(0x33FFFFFF) : t.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? (dark ? const Color(0xE6FFFFFF) : t.accent)
              : (dark ? const Color(0x59000000) : const Color(0x14000000)),
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? (dark ? t.canvas : Colors.white)
              : (dark ? const Color(0xFF8A93A6) : const Color(0xFF7A8296)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? Colors.white : t.accent,
        linearTrackColor: Colors.transparent,
        linearMinHeight: 2.5,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.onSurface.withValues(alpha: 0.16),
        thumbColor: Colors.white,
      ),
    );
  }

  BorderRadius _radius(PrismTokens t, PrismSurfaceKind kind) => switch (kind) {
    PrismSurfaceKind.bar => BorderRadius.circular(999),
    PrismSurfaceKind.panel => BorderRadius.circular(t.radiusXl),
    PrismSurfaceKind.card => BorderRadius.circular(t.radiusLg),
    PrismSurfaceKind.menu => BorderRadius.circular(t.radiusMd),
  };

  @override
  Widget buildSurface(BuildContext context, PrismSurface s) {
    final t = PrismTokens.of(context);
    return GlassMaterial(
      borderRadius: s.borderRadius ?? _radius(t, s.kind),
      padding: s.padding,
      tintBoost: s.kind == PrismSurfaceKind.menu ? 0.15 : 0,
      shadow: s.kind == PrismSurfaceKind.menu,
      borderColor: s.selected ? t.accent : null,
      borderWidth: s.selected ? 2 : 1,
      child: s.child,
    );
  }

  @override
  Widget buildToolbar(BuildContext context, PrismToolbar bar) {
    final density = densityOf(context);
    final t = PrismTokens.of(context);
    final top = bar.position == PrismToolbarPosition.top;
    final inset = top
        ? MediaQuery.paddingOf(context).top
        : MediaQuery.paddingOf(context).bottom;
    // Floating capsule with margins; content runs underneath (edge-to-edge).
    // A soft canvas fade behind the system bar keeps status icons legible
    // over any page (e.g. a white site under dark chrome).
    final Widget capsule = SafeArea(
      top: top && bar.safeArea,
      bottom: !top && bar.safeArea,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PrismSpace.md,
          vertical: PrismSpace.sm,
        ),
        child: PrismSurface(
          kind: PrismSurfaceKind.bar,
          padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
          child: SizedBox(
            height: density.barHeight,
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
    if (!bar.safeArea || inset <= 0) return capsule;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: top ? Alignment.topCenter : Alignment.bottomCenter,
          end: top ? Alignment.bottomCenter : Alignment.topCenter,
          stops: const [0, 0.45, 1],
          colors: [
            t.canvas.withValues(alpha: 0.72),
            t.canvas.withValues(alpha: 0.35),
            t.canvas.withValues(alpha: 0),
          ],
        ),
      ),
      child: capsule,
    );
  }

  @override
  Widget buildAddressField(BuildContext context, PrismAddressField f) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final empty = f.text.isEmpty;
    return Semantics(
      button: true,
      label: empty ? f.hint : f.text,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: f.onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            // 48dp: minimum touch target (fills the compact bar exactly).
            height: PrismSpace.touch,
            margin: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
            padding: const EdgeInsets.symmetric(horizontal: PrismSpace.md),
            decoration: BoxDecoration(
              color: t.onSurface.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                SecurityIcon(security: f.security, label: f.securityLabel),
                const SizedBox(width: PrismSpace.sm),
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
    );
  }

  @override
  Widget buildTabCard(BuildContext context, PrismTabCard c) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(t.radiusLg);
    return Semantics(
      selected: c.selected,
      button: true,
      label: c.title,
      child: GlassMaterial(
        borderRadius: radius,
        borderColor: c.selected
            ? t.accent
            : (c.incognito ? t.incognito.withValues(alpha: 0.6) : null),
        borderWidth: c.selected ? 2 : 1,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: c.onTap,
            borderRadius: radius,
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
                      PrismSpace.sm,
                      0,
                      PrismSpace.sm,
                      PrismSpace.sm,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(t.radiusMd - 4),
                      child: c.thumbnail ?? ThumbPlaceholder(host: c.host),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildButton(BuildContext context, PrismButton b) {
    final t = PrismTokens.of(context);
    // Ghost buttons have no lens; every other variant is a tinted glass pill.
    final GlassTone? tone = switch (b.variant) {
      PrismButtonVariant.primary => GlassTone.accent,
      PrismButtonVariant.secondary => GlassTone.neutral,
      PrismButtonVariant.ghost => null,
      PrismButtonVariant.danger => GlassTone.danger,
    };
    final fg = tone == null
        ? t.accent
        : GlassPillStyle.resolve(t, tone).foreground;
    final style = ButtonStyle(
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      minimumSize: const WidgetStatePropertyAll(Size(64, PrismSpace.touch)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: PrismSpace.xl),
      ),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? t.onSurface.withValues(alpha: 0.38)
            : fg,
      ),
      // Lens glow replaces the ripple; ghost keeps a soft hover layer.
      splashFactory: tone == null ? null : NoSplash.splashFactory,
      overlayColor: WidgetStatePropertyAll(
        tone == null ? t.onSurface.withValues(alpha: 0.08) : Colors.transparent,
      ),
      backgroundBuilder: tone == null
          ? null
          : (context, states, child) => GlassPill(
              tone: states.contains(WidgetState.disabled)
                  ? GlassTone.neutral
                  : tone,
              emphasis: _emphasis(states),
              child: child,
            ),
      side: focusRing(t),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      elevation: const WidgetStatePropertyAll(0),
    );
    final Widget button = b.icon == null
        ? TextButton(onPressed: b.onPressed, style: style, child: Text(b.label))
        : TextButton.icon(
            onPressed: b.onPressed,
            style: style,
            icon: Icon(b.icon, size: 18),
            label: Text(b.label),
          );
    return b.expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  @override
  Widget buildIconButton(BuildContext context, PrismIconButton b) {
    final t = PrismTokens.of(context);
    final lens = GlassPillStyle.resolve(t, GlassTone.accent);
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
        shape: const WidgetStatePropertyAll(CircleBorder()),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? t.onSurface.withValues(alpha: 0.38)
              : s.contains(WidgetState.selected)
              ? lens.foreground
              : t.onSurface,
        ),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        // Selected = accent lens (like the active nav item); otherwise a
        // clear lens fades in on hover/press only.
        backgroundBuilder: (context, states, child) {
          final selected = states.contains(WidgetState.selected);
          final e = _emphasis(states);
          if (!selected && e == 0) return child ?? const SizedBox.shrink();
          return AnimatedOpacity(
            opacity: selected ? 1 : e,
            duration: PrismMotion.of(context).fast,
            child: GlassPill(
              tone: selected ? GlassTone.accent : GlassTone.neutral,
              emphasis: selected ? e : 0,
              child: child,
            ),
          );
        },
        side: focusRing(t),
      ),
    );
  }

  /// Hover/focus brighten the lens a little, press brightens it fully.
  static double _emphasis(Set<WidgetState> s) {
    if (s.contains(WidgetState.disabled)) return 0;
    if (s.contains(WidgetState.pressed)) return 1;
    if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
      return 0.5;
    }
    return 0;
  }

  @override
  Widget buildSegmented<T>(BuildContext context, PrismSegmented<T> c) =>
      GlassSegmented<T>(control: c);

  @override
  Widget buildBackground(BuildContext context) => const PrismBackdrop();

  @override
  Widget buildIconBadge(BuildContext context, PrismIconBadge b) {
    final t = PrismTokens.of(context);
    final dark = t.canvas.computeLuminance() < 0.5;
    final radius = BorderRadius.circular(b.size * 0.32);
    // Dark accent badges are clear glass like every other dark lens;
    // semantic tones (secure / warning / danger) keep their tint.
    if (dark &&
        (b.tone == PrismBadgeTone.accent || b.tone == PrismBadgeTone.neutral)) {
      return SizedBox.square(
        dimension: b.size,
        child: GlassPill(
          tone: GlassTone.neutral,
          borderRadius: radius,
          child: Icon(b.icon, size: b.size * 0.5, color: t.onSurface),
        ),
      );
    }
    final c = badgeColor(t, b.tone);
    final icon = dark ? Color.lerp(c, Colors.white, 0.15)! : c;
    return Container(
      width: b.size,
      height: b.size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.withValues(alpha: dark ? 0.24 : 0.16),
            c.withValues(alpha: dark ? 0.12 : 0.08),
          ],
        ),
        border: Border.all(color: c.withValues(alpha: dark ? 0.35 : 0.25)),
      ),
      child: Icon(b.icon, size: b.size * 0.5, color: icon),
    );
  }

  @override
  Widget buildChip(BuildContext context, PrismChip c) {
    final t = PrismTokens.of(context);
    final tone = c.selected ? GlassTone.accent : GlassTone.neutral;
    final fg = GlassPillStyle.resolve(t, tone).foreground;
    return Semantics(
      button: true,
      selected: c.selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: c.onTap,
          customBorder: const StadiumBorder(),
          // 48dp hit area around a 36dp visual chip.
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: GlassPill(
              tone: tone,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PrismSpace.md,
                  vertical: PrismSpace.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.color != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: c.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: PrismSpace.sm),
                    ],
                    if (c.icon != null) ...[
                      Icon(c.icon, size: 16, color: fg),
                      const SizedBox(width: PrismSpace.xs + 2),
                    ],
                    Text(
                      c.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: c.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
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
  Widget buildSearchField(BuildContext context, PrismSearchField f) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    return GlassPill(
      tone: GlassTone.recessed,
      child: SizedBox(
        height: PrismSpace.touch,
        child: Row(
          children: [
            const SizedBox(width: PrismSpace.lg),
            Icon(
              f.leading ?? PrismIcons.search,
              size: 20,
              color: t.onSurfaceMuted,
            ),
            const SizedBox(width: PrismSpace.sm),
            Expanded(
              child: TextField(
                controller: f.controller,
                focusNode: f.focusNode,
                autofocus: f.autofocus,
                onChanged: f.onChanged,
                onSubmitted: f.onSubmitted,
                keyboardType: f.keyboardType,
                textInputAction: TextInputAction.go,
                style: text.bodyLarge,
                cursorColor: t.onSurface,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: f.hint,
                  hintStyle: text.bodyLarge?.copyWith(color: t.onSurfaceMuted),
                ),
              ),
            ),
            if (f.trailing != null) f.trailing!,
            const SizedBox(width: PrismSpace.xs),
          ],
        ),
      ),
    );
  }

  @override
  Future<T?> showSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
  }) {
    final t = PrismTokens.of(context);
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: t.scrim.withValues(alpha: 0.35),
      elevation: 0,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(PrismSpace.sm),
        child: PrismSurface(
          kind: PrismSurfaceKind.panel,
          padding: const EdgeInsets.fromLTRB(
            PrismSpace.xl,
            PrismSpace.sm,
            PrismSpace.xl,
            PrismSpace.xl,
          ),
          child: _SheetBody(title: title, builder: builder),
        ),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.builder});

  final String? title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 5,
            margin: const EdgeInsets.only(bottom: PrismSpace.lg),
            decoration: BoxDecoration(
              color: t.onSurface.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: PrismSpace.md),
        ],
        Flexible(child: builder(context)),
      ],
    );
  }
}
