import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/settings/appearance_controller.dart';
import '../../core/design/components/prism_address_field.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/design_registry.dart';
import '../../core/design/prism_design.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../browser/start_page.dart';

/// Live, real-component preview of the browser in [style], rendered with
/// that style's own theme regardless of the active one. Tapping selects it.
class StylePreviewCard extends ConsumerWidget {
  const StylePreviewCard({super.key, required this.style});

  final PrismStyleId style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(appearanceProvider);
    final selected = s.style == style;
    final text = Theme.of(context).textTheme;
    final t = PrismTokens.of(context);
    final design = designFor(style);
    final previewTheme = design.buildTheme(
      PrismThemeInput(
        brightness: Theme.of(context).brightness,
        seed: Theme.of(context).colorScheme.primary,
        density: s.density,
      ),
    );
    final name = style == PrismStyleId.glass ? l.styleGlass : l.styleMaterial;
    final desc = style == PrismStyleId.glass
        ? l.styleGlassDesc
        : l.styleMaterialDesc;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '$name. $desc',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => ref.read(appearanceProvider.notifier).setStyle(style),
        child: PrismSurface(
          kind: PrismSurfaceKind.card,
          selected: selected,
          padding: const EdgeInsets.all(PrismSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 9 / 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  child: Theme(
                    data: previewTheme,
                    child: PrismDesignScope(
                      design: design,
                      child: const IgnorePointer(
                        child: MediaQuery(
                          data: MediaQueryData(size: Size(360, 600)),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: 360,
                              height: 600,
                              child: _MiniBrowser(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PrismSpace.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
                child: Row(
                  children: [
                    Expanded(child: Text(name, style: text.titleMedium)),
                    if (selected)
                      Icon(PrismIcons.success, size: 20, color: t.onSurface),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PrismSpace.xs,
                  2,
                  PrismSpace.xs,
                  PrismSpace.xs,
                ),
                child: Text(desc, style: text.bodySmall, maxLines: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBrowser extends StatelessWidget {
  const _MiniBrowser();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          const Positioned.fill(
            child: StartPage(topInset: 72, bottomInset: 72, incognito: false),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PrismToolbar(
              middle: PrismAddressField(
                text: 'duckduckgo.com',
                hint: l.omniboxHint,
                security: PrismSecurity.secure,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PrismToolbar(
              position: PrismToolbarPosition.bottom,
              middle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Enabled look; the whole preview is under IgnorePointer.
                  PrismIconButton(
                    icon: PrismIcons.back,
                    tooltip: l.actionBack,
                    onPressed: () {},
                  ),
                  PrismIconButton(
                    icon: PrismIcons.add,
                    tooltip: l.actionNewTab,
                    onPressed: () {},
                  ),
                  PrismIconButton(
                    icon: PrismIcons.tabs,
                    tooltip: l.actionTabs,
                    selected: true,
                    onPressed: () {},
                  ),
                  PrismIconButton(
                    icon: PrismIcons.menu,
                    tooltip: l.actionMenu,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent palette + "from system". Selection is marked with a check icon
/// and a ring, not by color alone.
class AccentPicker extends ConsumerWidget {
  const AccentPicker({super.key});

  static const swatches = [
    0xFF7C6CF2,
    0xFF14B8A6,
    0xFF0EA5E9,
    0xFF22C55E,
    0xFFF59E0B,
    0xFFF97316,
    0xFFE11D48,
    0xFFEC4899,
  ];

  static String nameOf(AppLocalizations l, int argb) => switch (argb) {
    0xFF7C6CF2 => l.colorViolet,
    0xFF14B8A6 => l.colorTeal,
    0xFF0EA5E9 => l.colorSky,
    0xFF22C55E => l.colorGreen,
    0xFFF59E0B => l.colorAmber,
    0xFFF97316 => l.colorOrange,
    0xFFE11D48 => l.colorRose,
    _ => l.colorPink,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(appearanceProvider);
    final c = ref.read(appearanceProvider.notifier);
    final t = PrismTokens.of(context);
    return Wrap(
      spacing: PrismSpace.xs,
      runSpacing: PrismSpace.xs,
      children: [
        for (final argb in swatches)
          Semantics(
            button: true,
            selected: !s.useDynamicColor && s.seedColor == argb,
            label: nameOf(l, argb),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => c.setSeed(argb),
              radius: 26,
              child: SizedBox.square(
                dimension: PrismSpace.touch,
                child: Center(
                  child: AnimatedContainer(
                    duration: PrismMotion.of(context).fast,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(argb),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !s.useDynamicColor && s.seedColor == argb
                            ? t.onSurface
                            : Colors.transparent,
                        width: 2.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: !s.useDynamicColor && s.seedColor == argb
                        ? const Icon(
                            PrismIcons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
