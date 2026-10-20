import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';

/// Locale-aware byte size: "5,2 МБ" / "5.2 MB".
String formatBytes(AppLocalizations l, int bytes) {
  final f = NumberFormat('#,##0.#', l.localeName);
  if (bytes >= 1000000000) return l.unitGB(f.format(bytes / 1e9));
  if (bytes >= 1000000) return l.unitMB(f.format(bytes / 1e6));
  return l.unitKB(f.format(bytes / 1e3));
}

String formatTime(AppLocalizations l, DateTime t) =>
    DateFormat.Hm(l.localeName).format(t);

String formatDay(AppLocalizations l, DateTime t) =>
    DateFormat.MMMMd(l.localeName).format(t);
