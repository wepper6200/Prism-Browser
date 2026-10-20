import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/settings/appearance_controller.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_segmented.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import 'appearance_widgets.dart';

/// Settings -> Appearance. Every change applies live with an animated
/// theme transition, no restart.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(appearanceProvider);
    final c = ref.read(appearanceProvider.notifier);
    final text = Theme.of(context).textTheme;

    Widget block(String title, Widget child, {String? footer}) => Padding(
      padding: const EdgeInsets.only(bottom: PrismSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: PrismSpace.xs,
              bottom: PrismSpace.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(title.toUpperCase(), style: text.labelSmall),
            ),
          ),
          child,
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PrismSpace.xs,
                PrismSpace.sm,
                PrismSpace.xs,
                0,
              ),
              child: Text(footer, style: text.bodySmall),
            ),
        ],
      ),
    );

    return PrismPage(
      title: l.settingsAppearance,
      children: [
        block(
          l.appearanceStyle,
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StylePreviewCard(style: PrismStyleId.material)),
              SizedBox(width: PrismSpace.md),
              Expanded(child: StylePreviewCard(style: PrismStyleId.glass)),
            ],
          ),
        ),
        block(
          l.sectionTheme,
          PrismSegmented<PrismThemeMode>(
            segments: [
              PrismSegment(value: PrismThemeMode.system, label: l.themeSystem),
              PrismSegment(value: PrismThemeMode.light, label: l.themeLight),
              PrismSegment(value: PrismThemeMode.dark, label: l.themeDark),
            ],
            selected: s.themeMode,
            onChanged: c.setThemeMode,
          ),
        ),
        PrismSection(
          title: l.appearanceAccent,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.palette,
              title: l.accentDynamic,
              subtitle: l.accentDynamicSub,
              value: s.useDynamicColor,
              onChanged: c.setDynamicColor,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                PrismSpace.md,
                0,
                PrismSpace.md,
                PrismSpace.md,
              ),
              child: AccentPicker(),
            ),
          ],
        ),
        block(
          l.appearanceAddressBar,
          PrismSegmented<AddressBarPosition>(
            segments: [
              PrismSegment(
                value: AddressBarPosition.top,
                label: l.barTop,
                icon: PrismIcons.barTop,
              ),
              PrismSegment(
                value: AddressBarPosition.bottom,
                label: l.barBottom,
                icon: PrismIcons.barBottom,
              ),
            ],
            selected: s.addressBarPosition,
            onChanged: c.setAddressBar,
          ),
        ),
        block(
          l.appearanceDensity,
          PrismSegmented<UiDensity>(
            segments: [
              PrismSegment(
                value: UiDensity.comfortable,
                label: l.densityComfortable,
              ),
              PrismSegment(value: UiDensity.compact, label: l.densityCompact),
            ],
            selected: s.density,
            onChanged: c.setDensity,
          ),
        ),
        block(
          l.glassIntensity,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrismSegmented<GlassMode>(
                segments: [
                  PrismSegment(value: GlassMode.auto, label: l.glassAuto),
                  PrismSegment(value: GlassMode.manual, label: l.glassManual),
                  PrismSegment(value: GlassMode.off, label: l.glassOff),
                ],
                selected: s.glassMode,
                onChanged: c.setGlassMode,
              ),
              if (s.glassMode == GlassMode.manual)
                PrismSurface(
                  kind: PrismSurfaceKind.card,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PrismSpace.sm,
                  ),
                  child: Slider(
                    value: s.glassIntensity,
                    onChanged: c.setGlassIntensity,
                    semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                  ),
                ),
            ],
          ),
          footer: l.glassAutoHint,
        ),
        PrismSection(
          title: l.appearanceEffects,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.sparkle,
              title: l.reduceMotion,
              subtitle: l.reduceMotionSub,
              value: s.reduceMotion,
              onChanged: c.setReduceMotion,
            ),
          ],
        ),
      ],
    );
  }
}
