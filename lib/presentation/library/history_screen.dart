import 'package:flutter_riverpod/flutter_riverpod.dart';
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

enum ClearRange { hour, day, week, all }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _q = '';

  Future<void> _clear() async {
    final l = AppLocalizations.of(context);
    var range = ClearRange.day;
    await showPrismSheet<void>(
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
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(height: PrismSpace.sm),
            PrismButton(
              label: l.actionCancel,
              variant: PrismButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(clockProvider)();
    bool hit(String s) => s.toLowerCase().contains(_q.toLowerCase());
    final entries = ref
        .watch(historyProvider)
        .where((h) => hit(h.title) || hit(h.url))
        .toList();
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
        if (groups.isEmpty && _q.isEmpty)
          PrismEmptyState(
            icon: PrismIcons.history,
            title: l.emptyHistoryTitle,
            body: l.emptyHistoryBody,
          ),
        for (final MapEntry(key: title, value: items) in groups.entries)
          PrismSection(
            title: title,
            children: [
              for (final h in items)
                PrismTile(
                  leading: LetterFavicon(
                    label: h.title,
                    host: hostOf(h.url),
                    size: 40,
                  ),
                  title: h.title,
                  subtitle:
                      '${hostOf(h.url)} · ${title == l.historyEarlier ? formatDay(l, h.visitedAt) : formatTime(l, h.visitedAt)}',
                  onTap: () {},
                ),
            ],
          ),
      ],
    );
  }
}
