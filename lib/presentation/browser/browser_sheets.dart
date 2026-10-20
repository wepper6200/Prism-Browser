import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../data/mock/mock_data.dart';
import '../../domain/engine/url_resolver.dart';
import '../../l10n/gen/app_localizations.dart';

/// Main browser menu (sheet body). Navigation is done by the caller via
/// [onAction] so the sheet stays free of routing.
enum MenuAction {
  newTab,
  newIncognito,
  bookmarks,
  history,
  downloads,
  settings,
  find,
  share,
  pdf,
  bookmark,
  forgetAll,
}

class BrowserMenu extends ConsumerStatefulWidget {
  const BrowserMenu({super.key, required this.onAction});

  final ValueChanged<MenuAction> onAction;

  @override
  ConsumerState<BrowserMenu> createState() => _BrowserMenuState();
}

class _BrowserMenuState extends ConsumerState<BrowserMenu> {
  bool _reader = false;
  bool _desktop = false;
  int _zoom = 100;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final quick = [
      (PrismIcons.add, l.actionNewTab, MenuAction.newTab),
      (PrismIcons.incognito, l.menuNewIncognito, MenuAction.newIncognito),
      (PrismIcons.bookmark, l.menuBookmarks, MenuAction.bookmarks),
      (PrismIcons.history, l.menuHistory, MenuAction.history),
      (PrismIcons.downloads, l.menuDownloads, MenuAction.downloads),
      (PrismIcons.findInPage, l.menuFindInPage, MenuAction.find),
      (PrismIcons.share, l.menuShare, MenuAction.share),
      (PrismIcons.settings, l.actionSettings, MenuAction.settings),
    ];
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              for (final (icon, label, action) in quick)
                Semantics(
                  button: true,
                  label: label,
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => widget.onAction(action),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrismIconBadge(icon: icon, size: 48),
                        const SizedBox(height: PrismSpace.sm),
                        Text(
                          label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PrismSpace.md),
          PrismSection(
            children: [
              PrismSwitchTile(
                icon: PrismIcons.reader,
                title: l.menuReader,
                value: _reader,
                onChanged: (v) => setState(() => _reader = v),
              ),
              PrismSwitchTile(
                icon: PrismIcons.desktop,
                title: l.menuDesktopSite,
                value: _desktop,
                onChanged: (v) => setState(() => _desktop = v),
              ),
              PrismTile(
                icon: PrismIcons.zoom,
                title: l.menuZoom,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrismIconButton(
                      icon: PrismIcons.minus,
                      tooltip: l.menuZoomOut,
                      onPressed: _zoom > 50
                          ? () => setState(() => _zoom -= 10)
                          : null,
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$_zoom%',
                        textAlign: TextAlign.center,
                        style: text.labelLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    PrismIconButton(
                      icon: PrismIcons.add,
                      tooltip: l.menuZoomIn,
                      onPressed: _zoom < 300
                          ? () => setState(() => _zoom += 10)
                          : null,
                    ),
                  ],
                ),
              ),
              PrismTile(
                icon: PrismIcons.pdf,
                title: l.menuSavePdf,
                onTap: () => widget.onAction(MenuAction.pdf),
              ),
            ],
          ),
          PrismButton(
            label: l.menuForgetAll,
            icon: PrismIcons.broom,
            variant: PrismButtonVariant.danger,
            expand: true,
            onPressed: () => widget.onAction(MenuAction.forgetAll),
          ),
        ],
      ),
    );
  }
}

/// Per-site protection summary, opened from the shield chip.
class PrivacySheet extends ConsumerStatefulWidget {
  const PrivacySheet({super.key, this.onPermissions});

  final VoidCallback? onPermissions;

  @override
  ConsumerState<PrivacySheet> createState() => _PrivacySheetState();
}

class _PrivacySheetState extends ConsumerState<PrivacySheet> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final page = ref.watch(pageStateProvider);
    // Per-request details come from the blocker in stage 5; demo data
    // (tests, showcase) fills them in until then.
    final blocked = ref.watch(demoDataProvider)
        ? MockData.blockedOnPage
        : const <(String, bool, int)>[];
    final trackers = blocked
        .where((b) => !b.$2)
        .fold<int>(0, (s, b) => s + b.$3);
    final ads = blocked.where((b) => b.$2).fold<int>(0, (s, b) => s + b.$3);
    final secure = page.security == PageSecurity.secure;

    Widget stat(String value, String label, IconData icon) => Expanded(
      child: PrismSurface(
        kind: PrismSurfaceKind.card,
        padding: const EdgeInsets.symmetric(vertical: PrismSpace.md),
        child: Column(
          children: [
            Icon(icon, size: 20, color: t.onSurfaceMuted),
            const SizedBox(height: PrismSpace.xs),
            Text(value, style: text.titleLarge),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.shieldTitle(UrlResolver.display(page.url, full: false)),
            style: text.titleLarge,
          ),
          const SizedBox(height: PrismSpace.md),
          PrismSection(
            children: [
              PrismSwitchTile(
                icon: PrismIcons.shield,
                tone: PrismBadgeTone.secure,
                title: l.shieldOn,
                subtitle: l.shieldOnSub,
                value: _on,
                onChanged: (v) => setState(() => _on = v),
              ),
              PrismTile(
                icon: secure ? PrismIcons.lock : PrismIcons.lockOpen,
                tone: secure ? PrismBadgeTone.secure : PrismBadgeTone.warning,
                title: secure ? l.secureConnection : l.insecureConnection,
              ),
            ],
          ),
          Row(
            children: [
              stat('$trackers', l.statTrackers, PrismIcons.eyeSlash),
              const SizedBox(width: PrismSpace.sm),
              stat('$ads', l.statAds, PrismIcons.block),
              const SizedBox(width: PrismSpace.sm),
              stat(
                blocked.isEmpty ? '0' : '3',
                l.statCookies,
                PrismIcons.cookie,
              ),
            ],
          ),
          const SizedBox(height: PrismSpace.xl),
          if (blocked.isNotEmpty)
            PrismSection(
              title: l.shieldBlockedList,
              children: [
                for (final (host, isAd, count) in blocked)
                  PrismTile(
                    icon: isAd ? PrismIcons.block : PrismIcons.eyeSlash,
                    tone: isAd ? PrismBadgeTone.warning : PrismBadgeTone.danger,
                    title: host,
                    subtitle:
                        '${isAd ? l.kindAd : l.kindTracker} · ${l.requestsCount(count)}',
                  ),
              ],
            ),
          PrismTile(
            icon: PrismIcons.key,
            tone: PrismBadgeTone.neutral,
            title: l.settingsPermissions,
            chevron: true,
            onTap: widget.onPermissions,
          ),
        ],
      ),
    );
  }
}

/// Find-in-page bar shown above the bottom chrome.
class FindBar extends StatefulWidget {
  const FindBar({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<FindBar> createState() => _FindBarState();
}

class _FindBarState extends State<FindBar> {
  // Mock query until the engine provides find-in-page (stage 4).
  final _controller = TextEditingController(text: 'призма');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final onClose = widget.onClose;
    return PrismToolbar(
      position: PrismToolbarPosition.bottom,
      middle: PrismSearchField(
        controller: _controller,
        hint: l.menuFindInPage,
        leading: PrismIcons.findInPage,
        trailing: Padding(
          padding: const EdgeInsets.only(right: PrismSpace.sm),
          child: Text(l.findCount(2, 7), style: text.labelMedium),
        ),
      ),
      trailing: [
        PrismIconButton(
          icon: PrismIcons.chevronDown,
          tooltip: l.actionNext,
          onPressed: () {},
        ),
        PrismIconButton(
          icon: PrismIcons.close,
          tooltip: l.actionClose,
          onPressed: onClose,
        ),
      ],
    );
  }
}
