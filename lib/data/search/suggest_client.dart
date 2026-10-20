import 'dart:convert';
import 'dart:io';

import '../../domain/browser/models.dart';

/// Search suggestions from the selected engine (OpenSearch suggestions
/// JSON: `["query", ["s1", "s2", ...]]`). Only engines with a public,
/// keyless endpoint; Startpage and custom URLs get none.
abstract interface class SuggestClient {
  Future<List<String>> suggest(SearchEngineId engine, String query);
}

class HttpSuggestClient implements SuggestClient {
  HttpSuggestClient({HttpClient? client})
    : _client =
          client ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 3));

  final HttpClient _client;

  /// Endpoint for [engine], or null when it offers no keyless one.
  static Uri? endpoint(SearchEngineId engine, String q) => switch (engine) {
    SearchEngineId.duckduckgo => Uri.https('duckduckgo.com', '/ac/', {
      'q': q,
      'type': 'list',
    }),
    SearchEngineId.brave => Uri.https('search.brave.com', '/api/suggest', {
      'q': q,
    }),
    SearchEngineId.google => Uri.https(
      'suggestqueries.google.com',
      '/complete/search',
      {'client': 'firefox', 'q': q},
    ),
    SearchEngineId.bing => Uri.https('api.bing.com', '/osjson.aspx', {
      'query': q,
    }),
    SearchEngineId.yandex => Uri.https('suggest.yandex.ru', '/suggest-ff.cgi', {
      'part': q,
    }),
    SearchEngineId.startpage || SearchEngineId.custom => null,
  };

  static List<String> parse(String body) {
    final json = jsonDecode(body);
    if (json is! List || json.length < 2 || json[1] is! List) return const [];
    return [
      for (final s in json[1] as List)
        if (s is String && s.trim().isNotEmpty) s.trim(),
    ].take(5).toList();
  }

  @override
  Future<List<String>> suggest(SearchEngineId engine, String query) async {
    final uri = endpoint(engine, query.trim());
    if (uri == null || query.trim().isEmpty) return const [];
    try {
      final req = await _client.getUrl(uri);
      // No cookies, generic headers: suggestions must not identify users.
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close().timeout(const Duration(seconds: 3));
      if (res.statusCode != 200) {
        await res.drain<void>();
        return const [];
      }
      // Some engines answer in a legacy charset; malformed bytes are fine.
      final body = await res
          .transform(const Utf8Decoder(allowMalformed: true))
          .join();
      return parse(body);
    } on Object {
      return const [];
    }
  }
}
