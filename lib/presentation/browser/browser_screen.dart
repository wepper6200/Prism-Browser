import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../application/settings/appearance_controller.dart';
import '../../core/design/components/prism_address_field.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/effects_policy.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/engine/url_resolver.dart';
import '../../domain/search/prism_search.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../search/prism_search_page.dart';
import 'browser_sheets.dart';
import 'chrome_widgets.dart';
import 'desktop_chrome.dart';
import 'omnibox_panel.dart';
import 'page_host.dart';
import 'start_page.dart';

export 'chrome_widgets.dart' show BrowserPanel;

/// The browser: page content edge-to-edge with chrome floating (glass) or
/// docked (Material) above it. Phones get top/bottom bars, wide windows
/// (>= 840dp, Windows) get a tab strip and a desktop toolbar.
class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({
    super.key,
    this.initialPanel = BrowserPanel.none,
    this.initialQuery,
  });

  final BrowserPanel initialPanel;

  /// Prefills the omnibox (`/?panel=omnibox&q=...`, share-to-search).
  final String? initialQuery;

  static const double wideBreakpoint = 840;

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  BrowserPanel _panel = BrowserPanel.none;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPanel;
    if (p == BrowserPanel.omnibox || p == BrowserPanel.find) {
      _panel = p;
    } else if (p == BrowserPanel.menu || p == BrowserPanel.privacy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) p == BrowserPanel.menu ? _openMenu() : _openPrivacy();
      });
    }
  }

  void _setPanel(BrowserPanel p) => setState(() => _panel = p);

  void _open(String urlOrQuery) {
    _setPanel(BrowserPanel.none);
    ref.read(browserActionsProvider).open(urlOrQuery).ignore();
  }

  Future<void> _openMenu() async {
    final l = AppLocalizations.of(context);
    final action = await showPrismSheet<MenuAction>(
      context,
      title: l.actionMenu,
      builder: (ctx) => BrowserMenu(onAction: (a) => Navigator.of(ctx).pop(a)),
    );
    if (!mounted || action == null) return;
    final tabs = ref.read(tabsProvider.notifier);
    switch (action) {
      case MenuAction.newTab:
        tabs.newTab();
      case MenuAction.newIncognito:
        tabs.newTab(incognito: true);
      case MenuAction.bookmarks:
        context.push('/bookmarks').ignore();
      case MenuAction.history:
        context.push('/history').ignore();
      case MenuAction.downloads:
        context.push('/downloads').ignore();
      case MenuAction.settings:
        context.push('/settings').ignore();
      case MenuAction.find:
        _setPanel(BrowserPanel.find);
      case MenuAction.share:
      case MenuAction.pdf:
      case MenuAction.bookmark:
      case MenuAction.forgetAll:
        // Wired to the engine / storage in stages 3-5.
        break;
    }
  }

  Future<void> _openPrivacy() => showPrismSheet<void>(
    context,
    builder: (ctx) => PrivacySheet(
      onPermissions: () {
        Navigator.of(ctx).pop();
        context.push('/settings/permissions');
      },
    ),
  );

  Map<ShortcutActivator, VoidCallback> _shortcuts() {
    final tabs = ref.read(tabsProvider.notifier);
    return {
      const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
          tabs.newTab(),
      const SingleActivator(LogicalKeyboardKey.keyW, control: true): () =>
          tabs.close(ref.read(tabsProvider).activeId),
      const SingleActivator(LogicalKeyboardKey.keyL, control: true): () =>
          _setPanel(BrowserPanel.omnibox),
      const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
          _setPanel(BrowserPanel.find),
      const SingleActivator(LogicalKeyboardKey.keyH, control: true): () =>
          context.push('/history'),
      const SingleActivator(LogicalKeyboardKey.keyJ, control: true): () =>
          context.push('/downloads'),
      const SingleActivator(LogicalKeyboardKey.keyD, control: true): () =>
          context.push('/bookmarks'),
      const SingleActivator(LogicalKeyboardKey.tab, control: true): () {
        final s = ref.read(tabsProvider);
        final i = s.tabs.indexWhere((t) => t.id == s.activeId);
        tabs.select(s.tabs[(i + 1) % s.tabs.length].id);
      },
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          _setPanel(BrowserPanel.none),
    };
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(pageStateProvider);
    final wide =
        MediaQuery.sizeOf(context).width >= BrowserScreen.wideBreakpoint;
    final barBottom =
        !wide &&
        ref.watch(appearanceProvider.select((s) => s.addressBarPosition)) ==
            AddressBarPosition.bottom;
    final pad = MediaQuery.paddingOf(context);
    const bar = 72.0;
    final topInset = wide
        ? DesktopChrome.height
        : pad.top + (barBottom ? 0 : bar);
    final bottomInset = wide ? 0.0 : pad.bottom + bar * (barBottom ? 2 : 1);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = PrismSearchUri.queryOf(page.url);
    final onWeb = !page.isBlank && searchQuery == null;
    final insets = EdgeInsets.only(top: topInset, bottom: bottomInset);
    // Glass over a page Flutter cannot sample (Hybrid Composition) would
    // show sharp page text through the tint: use the opaque fallback.
    final effects = EffectsPolicy.of(context);
    final degrade =
        onWeb &&
        !ref.watch(engineProvider).capabilities.contentUnderChromeBlurs;

    final content = page.isBlank
        ? StartPage(
            topInset: topInset,
            bottomInset: bottomInset,
            incognito: page.tab.incognito,
            onSearchTap: () => _setPanel(BrowserPanel.omnibox),
            onOpen: _open,
          )
        : searchQuery != null
        ? PrismSearchPage(
            query: searchQuery,
            topInset: topInset,
            bottomInset: bottomInset,
          )
        : PageHost(tabId: page.tab.id, insets: insets);

    return PopScope(
      // Android back: close a panel, then go back in page history, then
      // leave the app (predictive back friendly).
      canPop: _panel == BrowserPanel.none && !page.canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_panel != BrowserPanel.none) {
          _setPanel(BrowserPanel.none);
        } else {
          ref.read(browserActionsProvider).back().ignore();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // White web page behind a bottom-only chrome needs dark status icons.
        value: (onWeb && barBottom) || !dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: CallbackShortcuts(
          bindings: _shortcuts(),
          child: Focus(
            autofocus: true,
            child: EffectsScope(
              policy: degrade ? effects.overUnblurrableContent() : effects,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    const Positioned.fill(child: PrismBackground()),
                    Positioned.fill(child: RepaintBoundary(child: content)),
                    if (wide)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: DesktopChrome(
                          page: page,
                          onOmnibox: () => _setPanel(BrowserPanel.omnibox),
                          onMenu: _openMenu,
                          onPrivacy: _openPrivacy,
                        ),
                      )
                    else ...[
                      if (!barBottom)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: _AddressBar(
                            page: page,
                            position: PrismToolbarPosition.top,
                            onOmnibox: () => _setPanel(BrowserPanel.omnibox),
                            onPrivacy: _openPrivacy,
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_panel == BrowserPanel.find)
                              FindBar(
                                onClose: () => _setPanel(BrowserPanel.none),
                              ),
                            if (barBottom)
                              _AddressBar(
                                page: page,
                                position: PrismToolbarPosition.bottom,
                                safeArea: false,
                                onOmnibox: () =>
                                    _setPanel(BrowserPanel.omnibox),
                                onPrivacy: _openPrivacy,
                              ),
                            _ActionBar(page: page, onMenu: _openMenu),
                          ],
                        ),
                      ),
                    ],
                    if (wide && _panel == BrowserPanel.find)
                      Positioned(
                        right: PrismSpace.lg,
                        top: DesktopChrome.height + PrismSpace.sm,
                        width: 440,
                        child: FindBar(
                          onClose: () => _setPanel(BrowserPanel.none),
                        ),
                      ),
                    if (_panel == BrowserPanel.omnibox)
                      Positioned.fill(
                        child: OmniboxPanel(
                          initialText:
                              widget.initialQuery ??
                              UrlResolver.display(page.url, full: true),
                          onClose: () => _setPanel(BrowserPanel.none),
                          onSubmit: _open,
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
}

class _AddressBar extends ConsumerWidget {
  const _AddressBar({
    required this.page,
    required this.position,
    required this.onOmnibox,
    required this.onPrivacy,
    this.safeArea = true,
  });

  final PageState page;
  final PrismToolbarPosition position;
  final VoidCallback onOmnibox;
  final VoidCallback onPrivacy;
  final bool safeArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final actions = ref.read(browserActionsProvider);
    final toolbar = PrismToolbar(
      position: position,
      safeArea: safeArea,
      middle: PrismAddressField(
        text: UrlResolver.display(page.url, full: false),
        hint: l.omniboxHint,
        security: switch (page.security) {
          PageSecurity.secure => PrismSecurity.secure,
          PageSecurity.insecure => PrismSecurity.insecure,
          PageSecurity.internal => PrismSecurity.internal,
        },
        securityLabel: switch (page.security) {
          PageSecurity.secure => l.secureConnection,
          PageSecurity.insecure => l.insecureConnection,
          PageSecurity.internal => null,
        },
        onTap: onOmnibox,
        trailing: page.isNative
            ? null
            : ShieldChip(count: page.blockedCount, onTap: onPrivacy),
      ),
      trailing: [
        PrismIconButton(
          icon: page.loading ? PrismIcons.stop : PrismIcons.reload,
          tooltip: page.loading ? l.actionStop : l.actionReload,
          onPressed: page.isBlank
              ? null
              : () =>
                    (page.loading ? actions.stop() : actions.reload()).ignore(),
        ),
      ],
    );
    if (!page.loading) return toolbar;
    final progress = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(value: page.progress),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: position == PrismToolbarPosition.top
          ? [
              toolbar,
              Transform.translate(
                offset: const Offset(0, -10),
                child: progress,
              ),
            ]
          : [
              Transform.translate(offset: const Offset(0, 10), child: progress),
              toolbar,
            ],
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.page, required this.onMenu});

  final PageState page;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final count = ref.watch(tabsProvider.select((s) => s.tabs.length));
    return PrismToolbar(
      position: PrismToolbarPosition.bottom,
      middle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PrismIconButton(
            icon: PrismIcons.back,
            tooltip: l.actionBack,
            onPressed: page.canGoBack
                ? () => ref.read(browserActionsProvider).back().ignore()
                : null,
          ),
          PrismIconButton(
            icon: PrismIcons.forward,
            tooltip: l.actionForward,
            onPressed: page.canGoForward
                ? () => ref.read(browserActionsProvider).forward().ignore()
                : null,
          ),
          PrismIconButton(
            icon: PrismIcons.add,
            tooltip: l.actionNewTab,
            onPressed: () => ref.read(tabsProvider.notifier).newTab(),
          ),
          TabsCountButton(count: count, onPressed: () => context.push('/tabs')),
          PrismIconButton(
            icon: PrismIcons.menu,
            tooltip: l.actionMenu,
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}
