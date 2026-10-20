import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_address_field.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../domain/engine/url_resolver.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/site_visuals.dart';
import 'chrome_widgets.dart';

/// Windows chrome: custom title bar with tab strip + toolbar, drawn by the
/// app (the native caption is hidden in stage 3). Window buttons are wired
/// to the runner in stage 3; here they are visual only.
class DesktopChrome extends ConsumerWidget {
  const DesktopChrome({
    super.key,
    required this.page,
    required this.onOmnibox,
    required this.onMenu,
    required this.onPrivacy,
  });

  /// top pad + tab row + gap + toolbar row + bottom pad.
  static const double height = 6 + 40 + 6 + 52 + 8;

  final PageState page;
  final VoidCallback onOmnibox;
  final VoidCallback onMenu;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tabs = ref.watch(tabsProvider);
    final actions = ref.read(browserActionsProvider);
    // Each group of controls is its own island (Glass: floating capsule;
    // Material: undecorated inside the docked bar).
    Widget island(Widget child, {EdgeInsets padding = EdgeInsets.zero}) =>
        PrismSurface(
          kind: PrismSurfaceKind.island,
          padding: padding,
          child: child,
        );

    return PrismSurface(
      kind: PrismSurfaceKind.chrome,
      padding: const EdgeInsets.fromLTRB(PrismSpace.sm, 6, PrismSpace.sm, 8),
      child: SizedBox(
        height: height - 14,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Flexible(
                    child: island(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final t in tabs.tabs)
                              _DesktopTab(
                                tab: t,
                                selected: t.id == tabs.activeId,
                                onTap: () => ref
                                    .read(tabsProvider.notifier)
                                    .select(t.id),
                                onClose: () =>
                                    ref.read(tabsProvider.notifier).close(t.id),
                              ),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: PrismIconButton(
                                icon: PrismIcons.add,
                                tooltip: '${l.actionNewTab} (Ctrl+T)',
                                onPressed: () =>
                                    ref.read(tabsProvider.notifier).newTab(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Draggable caption area (window drag wired with the runner).
                  const Spacer(),
                  const SizedBox(width: PrismSpace.sm),
                  island(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _WindowButton(
                          icon: PrismIcons.minus,
                          tooltip: l.windowMinimize,
                        ),
                        _WindowButton(
                          icon: PrismIcons.expand,
                          tooltip: l.windowMaximize,
                        ),
                        _WindowButton(
                          icon: PrismIcons.close,
                          tooltip: l.windowClose,
                          danger: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  island(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrismIconButton(
                          icon: PrismIcons.back,
                          tooltip: '${l.actionBack} (Alt+←)',
                          onPressed: page.canGoBack
                              ? () => actions.back().ignore()
                              : null,
                        ),
                        PrismIconButton(
                          icon: PrismIcons.forward,
                          tooltip: '${l.actionForward} (Alt+→)',
                          onPressed: page.canGoForward
                              ? () => actions.forward().ignore()
                              : null,
                        ),
                        PrismIconButton(
                          icon: PrismIcons.reload,
                          tooltip: '${l.actionReload} (F5)',
                          onPressed: page.isBlank
                              ? null
                              : () => actions.reload().ignore(),
                        ),
                        PrismIconButton(
                          icon: PrismIcons.home,
                          tooltip: l.actionHome,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PrismSpace.sm),
                  Expanded(
                    child: Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: island(
                          padding: const EdgeInsets.all(2),
                          PrismAddressField(
                            text: UrlResolver.display(page.url, full: true),
                            hint: l.omniboxHint,
                            security: switch (page.security) {
                              PageSecurity.secure => PrismSecurity.secure,
                              PageSecurity.insecure => PrismSecurity.insecure,
                              PageSecurity.internal => PrismSecurity.internal,
                            },
                            securityLabel: page.security == PageSecurity.secure
                                ? l.secureConnection
                                : null,
                            onTap: onOmnibox,
                            trailing: page.isNative
                                ? null
                                : ShieldChip(
                                    count: page.blockedCount,
                                    onTap: onPrivacy,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PrismSpace.sm),
                  island(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrismIconButton(
                          icon: PrismIcons.star,
                          tooltip: '${l.actionBookmark} (Ctrl+D)',
                          onPressed: () {},
                        ),
                        PrismIconButton(
                          icon: PrismIcons.downloads,
                          tooltip: '${l.menuDownloads} (Ctrl+J)',
                          onPressed: () => context.push('/downloads'),
                        ),
                        PrismIconButton(
                          icon: PrismIcons.incognito,
                          tooltip: l.menuNewIncognito,
                          onPressed: () => ref
                              .read(tabsProvider.notifier)
                              .newTab(incognito: true),
                        ),
                        PrismIconButton(
                          icon: PrismIcons.menu,
                          tooltip: l.actionMenu,
                          onPressed: onMenu,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTab extends StatelessWidget {
  const _DesktopTab({
    required this.tab,
    required this.selected,
    required this.onTap,
    required this.onClose,
  });

  final BrowserTab tab;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final title = tab.isStartPage
        ? l.actionNewTab
        : (tab.title.isEmpty ? tab.host : tab.title);
    final width = tab.pinned ? 48.0 : 200.0;
    final body = SizedBox(
      width: width,
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: PrismSpace.md),
          tab.isStartPage
              ? Icon(PrismIcons.globe, size: 16, color: t.onSurfaceMuted)
              : LetterFavicon(label: tab.title, host: tab.host, size: 16),
          if (!tab.pinned) ...[
            const SizedBox(width: PrismSpace.sm),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: text.labelLarge?.copyWith(
                  color: selected ? t.onSurface : t.onSurfaceMuted,
                ),
              ),
            ),
            InkResponse(
              onTap: onClose,
              radius: 14,
              child: Tooltip(
                message: '${l.actionCloseTab} (Ctrl+W)',
                child: Padding(
                  padding: const EdgeInsets.all(PrismSpace.sm),
                  child: Icon(
                    PrismIcons.close,
                    size: 14,
                    color: t.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Semantics(
        selected: selected,
        button: true,
        label: title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.radiusSm),
          child: selected
              ? PrismSurface(
                  kind: PrismSurfaceKind.card,
                  borderRadius: BorderRadius.circular(t.radiusSm),
                  child: body,
                )
              : body,
        ),
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {},
        // Rounded hover so it stays inside the window-controls island.
        customBorder: const StadiumBorder(),
        hoverColor: danger
            ? const Color(0xFFC42B1C)
            : t.onSurface.withValues(alpha: 0.08),
        child: SizedBox(
          width: 44,
          height: 40,
          child: Icon(icon, size: 16, color: t.onSurface),
        ),
      ),
    );
  }
}
