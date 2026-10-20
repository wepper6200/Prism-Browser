import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/site_visuals.dart';
import 'library_format.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _q = '';

  Future<void> _clear() async {
    final l = AppLocalizations.of(context);
    var range = ClearRange.hour;
    final confirmed = await showPrismSheet<bool>(
      context,
      title: l.historyClear,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrismSection(
              footer: l.clearHistoryBody,
              children: [
                for (final (r, label) in [
                  (ClearRange.hour, l.clearRangeHour),
                  (ClearRange.day, l.clearRangeDay),
                  (ClearRange.week, l.clearRangeWeek),
                  (ClearRange.all, l.clearRangeAll),
                ])
                  Semantics(
                    selected: r == range,
                    inMutuallyExclusiveGroup: true,
                    child: PrismTile(
                      title: label,
                      onTap: () => setSheet(() => range = r),
                      trailing: r == range
                          ? const Icon(PrismIcons.check, size: 22)
                          : const SizedBox(width: 22),
                    ),
                  ),
              ],
            ),
            PrismButton(
              label: l.actionDelete,
              icon: PrismIcons.delete,
              variant: PrismButtonVariant.danger,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: PrismSpace.sm),
            PrismButton(
              label: l.actionCancel,
              variant: PrismButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
    );
    if (confirmed ?? false) {
      await ref.read(historyActionsProvider).clear(range);
    }
  }

  void _open(HistoryEntry h) {
    ref.read(browserActionsProvider).open(h.url).ignore();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(clockProvider)();
    final entries = ref.watch(historyQueryProvider(_q)).value ?? const [];
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<HistoryEntry>>{};
    for (final h in entries) {
      final key = !h.visitedAt.isBefore(today)
          ? l.historyToday
          : (!h.visitedAt.isBefore(yesterday)
                ? l.historyYesterday
                : l.historyEarlier);
      (groups[key] ??= []).add(h);
    }
    return PrismPage(
      title: l.historyTitle,
      actions: [
        PrismIconButton(
          icon: PrismIcons.broom,
          tooltip: l.historyClear,
          onPressed: _clear,
        ),
      ],
      header: PrismSearchField(
        hint: l.historySearch,
        onChanged: (v) => setState(() => _q = v),
      ),
      children: [
        if (groups.isEmpty)
          _q.isEmpty
              ? PrismEmptyState(
                  icon: PrismIcons.history,
                  title: l.emptyHistoryTitle,
                  body: l.emptyHistoryBody,
                )
              : PrismEmptyState(
                  icon: PrismIcons.search,
                  title: l.emptySearchTitle,
                  body: l.emptySearchBody,
                ),
        for (final MapEntry(key: title, value: items) in groups.entries)
          PrismSection(
            title: title,
            children: [
              for (final h in items)
                PrismTile(
                  key: ValueKey(h.id),
                  leading: LetterFavicon(
                    label: h.title.isEmpty ? hostOf(h.url) : h.title,
                    host: hostOf(h.url),
                    size: 40,
                  ),
                  title: h.title.isEmpty ? hostOf(h.url) : h.title,
                  subtitle:
                      '${hostOf(h.url)} · ${title == l.historyEarlier ? formatDay(l, h.visitedAt) : formatTime(l, h.visitedAt)}',
                  onTap: () => _open(h),
                  trailing: PrismIconButton(
                    icon: PrismIcons.close,
                    tooltip: l.historyRemoveEntry,
                    onPressed: () =>
                        ref.read(historyActionsProvider).delete(h.id),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
