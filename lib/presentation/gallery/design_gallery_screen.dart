import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/settings/appearance_controller.dart';
import '../../core/design/components/prism_address_field.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_segmented.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/components/prism_tab_card.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/prism_backdrop.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';

/// Stage-1 showcase of every design-system component in the active style.
/// Also the target of the golden tests (both styles x light/dark).
class DesignGalleryScreen extends ConsumerWidget {
  const DesignGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(appearanceProvider);
    final c = ref.read(appearanceProvider.notifier);
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: PrismBackdrop()),
          ListView(
            padding: EdgeInsets.fromLTRB(
              PrismSpace.lg,
              topInset + 88,
              PrismSpace.lg,
              PrismSpace.xxxl,
            ),
            children: [
              Text(l.designGalleryTitle, style: text.headlineMedium),
              const SizedBox(height: PrismSpace.xl),
              _Section(
                title: l.sectionStyle,
                child: PrismSegmented<PrismStyleId>(
                  segments: [
                    PrismSegment(
                      value: PrismStyleId.glass,
                      label: l.styleGlass,
                      icon: PrismIcons.drop,
                    ),
                    PrismSegment(
                      value: PrismStyleId.material,
                      label: l.styleMaterial,
                      icon: PrismIcons.layers,
                    ),
                  ],
                  selected: s.style,
                  onChanged: c.setStyle,
                ),
              ),
              _Section(
                title: l.sectionTheme,
                child: PrismSegmented<PrismThemeMode>(
                  segments: [
                    PrismSegment(
                      value: PrismThemeMode.system,
                      label: l.themeSystem,
                    ),
                    PrismSegment(
                      value: PrismThemeMode.light,
                      label: l.themeLight,
                    ),
                    PrismSegment(
                      value: PrismThemeMode.dark,
                      label: l.themeDark,
                    ),
                  ],
                  selected: s.themeMode,
                  onChanged: c.setThemeMode,
                ),
              ),
              _Section(
                title: l.sectionButtons,
                child: Wrap(
                  spacing: PrismSpace.sm,
                  runSpacing: PrismSpace.sm,
                  children: [
                    PrismButton(
                      label: l.buttonPrimary,
                      icon: PrismIcons.globe,
                      onPressed: () {},
                    ),
                    PrismButton(
                      label: l.buttonSecondary,
                      variant: PrismButtonVariant.secondary,
                      onPressed: () {},
                    ),
                    PrismButton(
                      label: l.buttonGhost,
                      variant: PrismButtonVariant.ghost,
                      onPressed: () {},
                    ),
                    PrismButton(
                      label: l.actionCloseTab,
                      icon: PrismIcons.delete,
                      variant: PrismButtonVariant.danger,
                      onPressed: () {},
                    ),
                    PrismButton(label: l.buttonPrimary),
                  ],
                ),
              ),
              _Section(
                title: l.sectionIconButtons,
                child: Row(
                  children: [
                    PrismIconButton(
                      icon: PrismIcons.home,
                      tooltip: l.actionHome,
                      onPressed: () {},
                    ),
                    const SizedBox(width: PrismSpace.sm),
                    PrismIconButton(
                      icon: PrismIcons.bookmark,
                      selectedIcon: PrismIcons.bookmarkFilled,
                      tooltip: l.actionBookmark,
                      selected: true,
                      onPressed: () {},
                    ),
                    const SizedBox(width: PrismSpace.sm),
                    PrismIconButton(
                      icon: PrismIcons.settings,
                      tooltip: l.actionSettings,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              _Section(
                title: l.sectionSurfaces,
                child: PrismSurface(
                  kind: PrismSurfaceKind.card,
                  padding: const EdgeInsets.all(PrismSpace.lg),
                  child: Row(
                    children: [
                      Icon(
                        PrismIcons.shield,
                        color: PrismTokens.of(context).secure,
                      ),
                      const SizedBox(width: PrismSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.secureConnection, style: text.titleSmall),
                            Text(l.trackersBlocked(12), style: text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Section(
                title: l.sectionTabs,
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PrismTabCard(
                          title: 'DuckDuckGo',
                          host: 'duckduckgo.com',
                          selected: true,
                          closeTooltip: l.actionCloseTab,
                          onTap: () {},
                          onClose: () {},
                        ),
                      ),
                      const SizedBox(width: PrismSpace.md),
                      Expanded(
                        child: PrismTabCard(
                          title: 'Wikipedia',
                          host: 'wikipedia.org',
                          pinned: true,
                          closeTooltip: l.actionCloseTab,
                          onTap: () {},
                          onClose: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Section(
                title: l.sectionTypography,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.typeDisplay, style: text.displaySmall),
                    const SizedBox(height: PrismSpace.sm),
                    Text(l.typeTitle, style: text.titleLarge),
                    const SizedBox(height: PrismSpace.xs),
                    Text(l.typeBody, style: text.bodyLarge),
                    const SizedBox(height: PrismSpace.xs),
                    Text(l.typeLabel, style: text.labelSmall),
                  ],
                ),
              ),
              _Section(
                title: l.sectionControls,
                child: PrismSurface(
                  kind: PrismSurfaceKind.card,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PrismSpace.lg,
                    vertical: PrismSpace.sm,
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.reduceMotion),
                        value: s.reduceMotion,
                        onChanged: c.setReduceMotion,
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(l.glassIntensity)),
                          SizedBox(
                            width: 180,
                            child: Slider(
                              value: s.glassMode == GlassMode.off
                                  ? 0
                                  : (s.glassMode == GlassMode.auto
                                        ? 1
                                        : s.glassIntensity),
                              onChanged: c.setGlassIntensity,
                              semanticFormatterCallback: (v) =>
                                  '${(v * 100).round()}%',
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: PrismButton(
                          label: l.actionShowSheet,
                          variant: PrismButtonVariant.secondary,
                          onPressed: () => showPrismSheet<void>(
                            context,
                            title: l.sheetTitle,
                            builder: (ctx) => Text(
                              l.sheetBody,
                              style: Theme.of(ctx).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: PrismSpace.sm),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PrismToolbar(
              leading: [
                PrismIconButton(
                  icon: PrismIcons.back,
                  tooltip: l.actionBack,
                  onPressed: () {},
                ),
              ],
              middle: PrismAddressField(
                text: 'duckduckgo.com',
                hint: l.omniboxHint,
                security: PrismSecurity.secure,
                securityLabel: l.secureConnection,
                onTap: () {},
              ),
              trailing: [
                PrismIconButton(
                  icon: PrismIcons.tabs,
                  tooltip: l.actionTabs,
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
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: PrismSpace.sm),
          child,
        ],
      ),
    );
  }
}
