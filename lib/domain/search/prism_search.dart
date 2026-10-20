import 'package:flutter/foundation.dart';

import '../browser/models.dart';

/// Prism Search: the browser's own results page. It needs no server and no
/// API key: answers are computed on the device (calculator, open tabs,
/// bookmarks, history) plus an optional encyclopedia lookup; full web
/// results are one tap away on the user's chosen web engine.
abstract final class PrismSearchUri {
  static const scheme = 'prism';
  static const host = 'search';

  /// Query template for [SearchEngine.queryTemplate].
  static const template = 'prism://search?q=%s';

  static Uri forQuery(String query) =>
      Uri(scheme: scheme, host: host, queryParameters: {'q': query.trim()});

  /// The query of a Prism Search URL, or null for any other URL.
  static String? queryOf(Uri? url) {
    if (url == null || url.scheme != scheme || url.host != host) return null;
    final q = url.queryParameters['q']?.trim();
    return q == null || q.isEmpty ? null : q;
  }
}

enum LocalMatchKind { tab, bookmark, history }

@immutable
class LocalMatch {
  const LocalMatch({
    required this.kind,
    required this.title,
    required this.url,
    this.tabId,
  });

  final LocalMatchKind kind;
  final String title;
  final String url;

  /// Set for open tabs: tapping switches to the tab instead of reloading.
  final String? tabId;
}

/// Matches a query against what is already on the device.
abstract final class LocalSearch {
  /// Every query word must appear in the title or URL. Ranked: title
  /// prefix, title word, URL; one row per URL (open tab > bookmark >
  /// history).
  static List<LocalMatch> match(
    String query, {
    List<BrowserTab> tabs = const [],
    List<Bookmark> bookmarks = const [],
    List<HistoryEntry> history = const [],
    int limit = 6,
  }) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];

    int? score(String title, String url) {
      final t = title.toLowerCase();
      final u = url.toLowerCase();
      var s = 0;
      for (final w in words) {
        if (t.startsWith(w)) {
          s += 3;
        } else if (t.contains(' $w') || t.contains(w)) {
          s += 2;
        } else if (u.contains(w)) {
          s += 1;
        } else {
          return null;
        }
      }
      return s;
    }

    final seen = <String>{};
    final scored = <(int, int, LocalMatch)>[];
    void add(LocalMatch m, int kindRank) {
      final key = _normalize(m.url);
      if (m.url.isEmpty || seen.contains(key)) return;
      final s = score(m.title, m.url);
      if (s == null) return;
      seen.add(key);
      scored.add((s, kindRank, m));
    }

    for (final t in tabs) {
      if (t.incognito || t.url.isEmpty) continue;
      if (PrismSearchUri.queryOf(Uri.tryParse(t.url)) != null) continue;
      add(
        LocalMatch(
          kind: LocalMatchKind.tab,
          title: t.title.isEmpty ? t.host : t.title,
          url: t.url,
          tabId: t.id,
        ),
        0,
      );
    }
    for (final b in bookmarks) {
      add(
        LocalMatch(kind: LocalMatchKind.bookmark, title: b.title, url: b.url),
        1,
      );
    }
    for (final h in history) {
      add(
        LocalMatch(kind: LocalMatchKind.history, title: h.title, url: h.url),
        2,
      );
    }
    scored.sort((a, b) {
      final byScore = b.$1.compareTo(a.$1);
      return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
    });
    return [for (final s in scored.take(limit)) s.$3];
  }

  static String _normalize(String url) {
    var u = url.toLowerCase();
    u = u.replaceFirst(RegExp(r'^https?://(www\.)?'), '');
    return u.endsWith('/') ? u.substring(0, u.length - 1) : u;
  }
}

/// One encyclopedia article matching the query.
@immutable
class KnowledgePage {
  const KnowledgePage({
    required this.title,
    required this.url,
    this.extract = '',
    this.description = '',
    this.thumbnail,
  });

  final String title;
  final Uri url;

  /// Plain-text intro (first sentences), may be empty.
  final String extract;

  /// Short description ("Capital of France"), may be empty.
  final String description;
  final Uri? thumbnail;
}

/// Answers from an encyclopedia for a query (Wikipedia by default). The
/// first page is the instant answer, the rest are related articles.
abstract interface class KnowledgeSource {
  /// Human-readable name shown on the answer card.
  String get name;

  /// [lang] is a BCP-47 language code (`ru`, `en`).
  Future<List<KnowledgePage>> search(String query, {required String lang});
}
