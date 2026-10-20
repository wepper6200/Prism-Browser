import 'dart:convert';
import 'dart:io';

import '../../domain/search/prism_search.dart';

/// Instant answers from Wikipedia's public API (no key, no account).
///
/// Privacy: one HTTPS request per Prism Search results page, sent only
/// after the user submits a query (never while typing), with no cookies
/// and a generic User-Agent. Wikimedia's privacy policy applies to it.
class WikipediaSource implements KnowledgeSource {
  WikipediaSource({
    HttpClient? client,
    this.timeout = const Duration(seconds: 6),
  }) : _client = client ?? HttpClient();

  final HttpClient _client;
  final Duration timeout;

  static const userAgent =
      'PrismBrowser/0.1 (https://github.com/wepper6200/Prism-Browser)';
  static final _lang = RegExp(r'^[a-z]{2,3}$');

  @override
  String get name => 'Wikipedia';

  /// API URL for [query]; [lang] falls back to `en` unless it is a plain
  /// language code (it becomes part of the host name).
  static Uri requestUri(String query, String lang) {
    final l = _lang.hasMatch(lang) ? lang : 'en';
    return Uri.https('$l.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'formatversion': '2',
      'redirects': '1',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '0',
      'gsrlimit': '5',
      'prop': 'extracts|pageimages|description|info',
      'exintro': '1',
      'explaintext': '1',
      'exsentences': '3',
      'exlimit': '5',
      'piprop': 'thumbnail',
      'pithumbsize': '160',
      'pilimit': '5',
      'inprop': 'url',
    });
  }

  @override
  Future<List<KnowledgePage>> search(
    String query, {
    required String lang,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final request = await _client.getUrl(requestUri(q, lang)).timeout(timeout);
    request.headers
      ..set(HttpHeaders.userAgentHeader, userAgent)
      ..set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(timeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('Wikipedia: HTTP ${response.statusCode}');
    }
    final body = await response.transform(utf8.decoder).join().timeout(timeout);
    return parse(body);
  }

  /// Parses an `action=query` response, best match first. Pages without a
  /// valid https URL are dropped.
  static List<KnowledgePage> parse(String body) {
    final json = jsonDecode(body);
    if (json is! Map) return const [];
    final pages = (json['query'] as Map?)?['pages'];
    if (pages is! List) return const [];
    final sorted = pages.whereType<Map<String, dynamic>>().toList()
      ..sort(
        (a, b) => ((a['index'] as num?) ?? 999).compareTo(
          (b['index'] as num?) ?? 999,
        ),
      );
    return [
      for (final p in sorted)
        if (_https(p['fullurl']) case final url?)
          KnowledgePage(
            title: (p['title'] as String?) ?? '',
            url: url,
            extract: _clean((p['extract'] as String?) ?? ''),
            description: (p['description'] as String?) ?? '',
            thumbnail: _https((p['thumbnail'] as Map?)?['source']),
          ),
    ];
  }

  static Uri? _https(Object? value) {
    if (value is! String) return null;
    final u = Uri.tryParse(value);
    return u != null && u.scheme == 'https' && u.host.isNotEmpty ? u : null;
  }

  /// Intro text without empty parentheses left by stripped markup.
  static String _clean(String s) => s
      .replaceAll(RegExp(r'\s*\(\s*[;,]?\s*\)'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
