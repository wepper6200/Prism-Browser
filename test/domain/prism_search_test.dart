import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/data/search/wikipedia_source.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/engine/url_resolver.dart';
import 'package:prism_browser/domain/search/calculator.dart';
import 'package:prism_browser/domain/search/prism_search.dart';

void main() {
  group('Calculator', () {
    test('evaluates with precedence, parentheses and powers', () {
      expect(Calculator.tryEvaluate('2+2*3'), 8);
      expect(Calculator.tryEvaluate('(2+2)*3'), 12);
      expect(Calculator.tryEvaluate('2^3^2'), 512);
      expect(Calculator.tryEvaluate('10 / 4'), 2.5);
      expect(Calculator.tryEvaluate('7 × 6 ='), 42);
      expect(Calculator.tryEvaluate('9 ÷ 3'), 3);
      expect(Calculator.tryEvaluate('-3 + 5'), 2);
      expect(Calculator.tryEvaluate('2 * -3'), -6);
    });

    test('decimal comma and percent', () {
      expect(Calculator.tryEvaluate('1,5 + 1,5'), 3);
      expect(Calculator.tryEvaluate('15% * 80'), closeTo(12, 1e-9));
      expect(Calculator.tryEvaluate('2 ^ 0.5'), closeTo(1.41421356, 1e-8));
    });

    test('is not an answer for non-expressions', () {
      for (final s in [
        '42',
        'погода',
        'iphone 15',
        '2026-10-20',
        '8-800-555-35-35',
        '12:30',
        '1/0',
        '(2+3',
        '2 +',
        '',
      ]) {
        expect(Calculator.tryEvaluate(s), isNull, reason: s);
      }
    });
  });

  group('PrismSearchUri', () {
    test('round-trips queries with special characters', () {
      final u = PrismSearchUri.forQuery('  кошки & собаки?  ');
      expect(u.scheme, 'prism');
      expect(PrismSearchUri.queryOf(u), 'кошки & собаки?');
    });

    test('ignores other URLs and empty queries', () {
      expect(PrismSearchUri.queryOf(Uri.parse('https://search?q=x')), isNull);
      expect(PrismSearchUri.queryOf(Uri.parse('prism://search?q=')), isNull);
      expect(PrismSearchUri.queryOf(null), isNull);
    });

    test('the omnibox resolves searches to Prism Search by default', () {
      final prism = SearchEngine.byId(SearchEngineId.prism);
      final uri = UrlResolver.resolve(
        'рецепт борща',
        searchTemplate: prism.queryTemplate,
      );
      expect(PrismSearchUri.queryOf(uri), 'рецепт борща');
      // Addresses still open directly.
      expect(
        UrlResolver.resolve('example.com', searchTemplate: prism.queryTemplate),
        Uri.parse('https://example.com'),
      );
    });

    test('address bar shows the query, not the internal URL', () {
      final u = PrismSearchUri.forQuery('flutter');
      expect(UrlResolver.display(u, full: true), 'flutter');
      expect(UrlResolver.display(u, full: false), 'flutter');
    });

    test('Prism Search is the default and not a web engine', () {
      expect(SearchEngine.all.first.isPrism, isTrue);
      expect(SearchEngine.web.any((e) => e.isPrism), isFalse);
      expect(SearchEngine.web.map((e) => e.id), contains(SearchEngineId.brave));
    });
  });

  group('LocalSearch', () {
    final tabs = [
      const BrowserTab(
        id: 't1',
        title: 'Flutter docs',
        url: 'https://docs.flutter.dev/',
      ),
      const BrowserTab(
        id: 't2',
        title: 'Secret',
        url: 'https://flutter.dev',
        incognito: true,
      ),
    ];
    final bookmarks = [
      const Bookmark(
        id: 'b1',
        title: 'Flutter docs',
        url: 'https://docs.flutter.dev',
      ),
      const Bookmark(id: 'b2', title: 'Dart packages', url: 'https://pub.dev'),
    ];
    final history = [
      HistoryEntry(
        id: 'h1',
        title: 'Learn Flutter widgets',
        url: 'https://example.com/flutter',
        visitedAt: DateTime(2026),
      ),
      HistoryEntry(
        id: 'h2',
        title: 'Weather',
        url: 'https://weather.example',
        visitedAt: DateTime(2026),
      ),
    ];

    test('every word must match; open tab wins over duplicates', () {
      final m = LocalSearch.match(
        'flutter',
        tabs: tabs,
        bookmarks: bookmarks,
        history: history,
      );
      expect(m.map((e) => e.kind), [
        LocalMatchKind.tab,
        LocalMatchKind.history,
      ]);
      expect(m.first.tabId, 't1');
      expect(
        LocalSearch.match('flutter widgets', history: history).single.title,
        'Learn Flutter widgets',
      );
      expect(LocalSearch.match('flutter cats', history: history), isEmpty);
    });

    test('never surfaces incognito tabs', () {
      final m = LocalSearch.match('secret', tabs: tabs);
      expect(m, isEmpty);
    });

    test('URL matches rank below title matches', () {
      final m = LocalSearch.match(
        'pub',
        bookmarks: bookmarks,
        history: [
          HistoryEntry(
            id: 'h',
            title: 'Pub quiz',
            url: 'https://quiz.example',
            visitedAt: DateTime(2026),
          ),
        ],
      );
      expect(m.first.title, 'Pub quiz');
    });
  });

  group('WikipediaSource', () {
    test('request goes to the language wiki; bad codes fall back to en', () {
      final u = WikipediaSource.requestUri('Париж', 'ru');
      expect(u.scheme, 'https');
      expect(u.host, 'ru.wikipedia.org');
      expect(u.queryParameters['gsrsearch'], 'Париж');
      expect(
        WikipediaSource.requestUri('x', 'evil.com/').host,
        'en.wikipedia.org',
      );
    });

    test('parses pages in search order and drops unsafe URLs', () {
      const body = '''
{"query":{"pages":[
 {"pageid":2,"index":2,"title":"Paris Hilton","fullurl":"https://en.wikipedia.org/wiki/Paris_Hilton","extract":"An American media personality."},
 {"pageid":1,"index":1,"title":"Paris","fullurl":"https://en.wikipedia.org/wiki/Paris","description":"Capital of France","extract":"Paris ( ) is the capital   of France.","thumbnail":{"source":"https://upload.wikimedia.org/p.jpg"}},
 {"pageid":3,"index":3,"title":"Bad","fullurl":"javascript:alert(1)"}
]}}''';
      final pages = WikipediaSource.parse(body);
      expect(pages.map((p) => p.title), ['Paris', 'Paris Hilton']);
      expect(pages.first.extract, 'Paris is the capital of France.');
      expect(pages.first.description, 'Capital of France');
      expect(pages.first.thumbnail?.host, 'upload.wikimedia.org');
    });

    test('empty or unexpected responses give no pages', () {
      expect(WikipediaSource.parse('{"batchcomplete":true}'), isEmpty);
      expect(WikipediaSource.parse('[]'), isEmpty);
    });
  });
}
