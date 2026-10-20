import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_segmented.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/components/prism_tab_card.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/site_visuals.dart';

/// Grid tab switcher. Swipe a card sideways to close it; long-press for
/// pin / duplicate / close. Unloaded tabs (memory pressure) are dimmed and
/// restored lazily on selection.
class TabSwitcherScreen extends ConsumerStatefulWidget {
  const TabSwitcherScreen({super.key, this.incognito = false});

  final bool incognito;

  @override
  ConsumerState<TabSwitcherScreen> createState() => _TabSwitcherScreenState();
}

class _TabSwitcherScreenState extends ConsumerState<TabSwitcherScreen> {
  late bool _incognito = widget.incognito;
  String? _group;

  void _select(String id) {
    ref.read(tabsProvider.notifier).select(id);
    context.canPop() ? context.pop() : context.go('/');
  }

  Future<void> _actions(BrowserTab tab) async {
    final l = AppLocalizations.of(context);
    final c = ref.read(tabsProvider.notifier);
    await showPrismSheet<void>(
      context,
      title: tab.title.isEmpty ? l.actionNewTab : tab.title,
      builder: (ctx) => PrismSection(
        children: [
          PrismTile(
            icon: tab.pinned ? PrismIcons.pinFilled : PrismIcons.pin,
            title: l.menuPin,
            onTap: () {
              c.togglePin(tab.id);
              Navigator.of(ctx).pop();
            },
          ),
          PrismTile(
            icon: PrismIcons.copy,
            title: l.menuDuplicate,
            onTap: () {
              c.duplicate(tab.id);
              Navigator.of(ctx).pop();
            },
          ),
          PrismTile(
            icon: PrismIcons.close,
            tone: PrismBadgeTone.danger,
            title: l.actionCloseTab,
            onTap: () {
              c.close(tab.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final state = ref.watch(tabsProvider);
    final pad = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 4 : (width >= 700 ? 3 : 2);
    final all = _incognito ? state.incognitoTabs : state.tabs;
    final tabs = _group == null
        ? all
        : all.where((t) => t.groupId == _group).toList();
    // Pinned first, keep relative order (stable keys keep animations calm).
    final ordered = [
      ...tabs.where((t) => t.pinned),
      ...tabs.where((t) => !t.pinned),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: PrismBackground()),
          if (ordered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(PrismSpace.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PrismIconBadge(
                      icon: PrismIcons.incognito,
                      tone: PrismBadgeTone.neutral,
                      size: 64,
                    ),
                    const SizedBox(height: PrismSpace.lg),
                    Text(l.tabsEmptyIncognito, style: text.titleLarge),
                    const SizedBox(height: PrismSpace.sm),
                    Text(
                      l.tabsEmptyIncognitoBody,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    PrismSpace.lg,
                    pad.top + 84,
                    PrismSpace.lg,
                    PrismSpace.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _incognito
                        ? const SizedBox.shrink()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                PrismChip(
                                  label: l.tabsAllGroups,
                                  selected: _group == null,
                                  onTap: () => setState(() => _group = null),
                                ),
                                for (final g in state.groups) ...[
                                  const SizedBox(width: PrismSpace.sm),
                                  PrismChip(
                                    label: g.name,
                                    color: Color(g.color),
                                    selected: _group == g.id,
                                    onTap: () => setState(() => _group = g.id),
                                  ),
                                ],
                              ],
                            ),
                          ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    PrismSpace.lg,
                    PrismSpace.sm,
                    PrismSpace.lg,
                    pad.bottom + 96,
                  ),
                  sliver: SliverGrid.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: PrismSpace.md,
                    crossAxisSpacing: PrismSpace.md,
                    childAspectRatio: 0.72,
                    children: [
                      for (final tab in ordered)
                        Dismissible(
                          key: ValueKey(tab.id),
                          onDismissed: (_) =>
                              ref.read(tabsProvider.notifier).close(tab.id),
                          child: GestureDetector(
                            onLongPress: () => _actions(tab),
                            child: _Card(
                              tab: tab,
                              selected: tab.id == state.activeId,
                              onTap: () => _select(tab.id),
                              onClose: () =>
                                  ref.read(tabsProvider.notifier).close(tab.id),
                            ),
                          ),
                        ),
                    ],
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
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ],
              middle: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: PrismSegmented<bool>(
                    segments: [
                      PrismSegment(
                        value: false,
                        label: '${l.tabsNormal} · ${state.tabs.length}',
                      ),
                      PrismSegment(
                        value: true,
                        label: l.tabsIncognito,
                        icon: PrismIcons.incognito,
                      ),
                    ],
                    selected: _incognito,
                    onChanged: (v) => setState(() {
                      _incognito = v;
                      _group = null;
                    }),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PrismToolbar(
              position: PrismToolbarPosition.bottom,
              leading: [
                PrismButton(
                  label: l.tabsCloseAll,
                  variant: PrismButtonVariant.ghost,
                  onPressed: _incognito
                      ? () => ref.read(tabsProvider.notifier).clearIncognito()
                      : null,
                ),
              ],
              middle: const SizedBox.shrink(),
              trailing: [
                PrismButton(
                  // Short label: "New incognito tab" overflows phone bars;
                  // the incognito icon carries the mode.
                  label: l.actionNewTab,
                  icon: _incognito ? PrismIcons.incognito : PrismIcons.add,
                  onPressed: () {
                    ref
                        .read(tabsProvider.notifier)
                        .newTab(incognito: _incognito);
                    context.canPop() ? context.pop() : context.go('/');
                  },
                ),
                const SizedBox(width: PrismSpace.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
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
    final title = tab.isStartPage
        ? l.actionNewTab
        : (tab.title.isEmpty ? tab.host : tab.title);
    Widget thumb = tab.isStartPage
        ? Center(
            child: Icon(PrismIcons.globe, size: 32, color: t.onSurfaceMuted),
          )
        : SiteThumbnail(tab: tab);
    if (!tab.loaded) {
      thumb = Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: 0.45, child: thumb),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(PrismSpace.sm),
              child: Tooltip(
                message: l.tabsUnloaded,
                child: Icon(PrismIcons.dark, size: 18, color: t.onSurfaceMuted),
              ),
            ),
          ),
        ],
      );
    }
    return PrismTabCard(
      title: title,
      host: tab.host,
      selected: selected,
      pinned: tab.pinned,
      incognito: tab.incognito,
      favicon: tab.isStartPage
          ? null
          : LetterFavicon(label: tab.title, host: tab.host),
      thumbnail: thumb,
      closeTooltip: l.actionCloseTab,
      onTap: onTap,
      onClose: onClose,
    );
  }
}
