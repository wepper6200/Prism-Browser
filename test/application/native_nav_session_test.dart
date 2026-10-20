import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/application/browser/native_nav_session.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/domain/search/prism_search.dart';

void main() {
  late FakeEngine engine;
  NativeNavSession session({Uri? url, String? query}) => NativeNavSession(
    engine.createSession(tabId: 't', incognito: false, initialUrl: url),
    initialQuery: query,
  );

  final a = Uri.parse('https://a.example/');
  final r1 = Uri.parse('https://r1.example/');
  final r2 = Uri.parse('https://r2.example/');
  Uri search(String q) => PrismSearchUri.forQuery(q);

  setUp(() => engine = FakeEngine());

  test('start page → search → result → Back → search → Back → start', () async {
    final s = session();
    expect(s.state.value.isBlank, isTrue);

    await s.load(search('cats'));
    expect(PrismSearchUri.queryOf(s.state.value.url), 'cats');
    expect(s.state.value.canGoBack, isTrue);
    expect(engine.loadLog, isEmpty, reason: 'native page, no network');

    await s.load(r1);
    expect(s.state.value.url, r1);
    expect(s.state.value.canGoBack, isTrue, reason: 'back to the results');

    await s.goBack();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'cats');

    await s.goBack();
    expect(s.state.value.isBlank, isTrue);
    expect(s.state.value.canGoBack, isFalse);
  });

  test('a second result after Back replaces the first', () async {
    final s = session();
    await s.load(search('cats'));
    await s.load(r1);
    await s.goBack();
    await s.load(r2);
    expect(s.state.value.url, r2);
    await s.goBack();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'cats');
    await s.goBack();
    expect(s.state.value.isBlank, isTrue);
  });

  test('search over a site returns to that site', () async {
    final s = session(url: a);
    await s.load(search('dogs'));
    await s.load(r1);
    await s.goBack();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'dogs');
    await s.goBack();
    expect(s.state.value.url, a);
    expect(s.state.value.canGoBack, isFalse);
  });

  test('links inside a result go back within the site first', () async {
    final s = session();
    await s.load(search('cats'));
    await s.load(r1);
    await s.load(r2); // a link followed on r1
    await s.goBack();
    expect(s.state.value.url, r1);
    await s.goBack();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'cats');
  });

  test('Forward returns to the result and to a popped search', () async {
    final s = session(url: a);
    await s.load(search('dogs'));
    await s.load(r1);
    await s.goBack();
    expect(s.state.value.canGoForward, isTrue);
    await s.goForward();
    expect(s.state.value.url, r1);

    await s.goBack(); // results
    await s.goBack(); // site a
    expect(s.state.value.url, a);
    await s.goForward();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'dogs');
    await s.goForward();
    expect(s.state.value.url, r1);
  });

  test('a new search from the results page stacks on it', () async {
    final s = session();
    await s.load(search('cats'));
    await s.load(search('kittens'));
    await s.goBack();
    expect(PrismSearchUri.queryOf(s.state.value.url), 'cats');
  });

  test('restored tab opens on its search page', () {
    final s = session(query: 'saved');
    expect(PrismSearchUri.queryOf(s.state.value.url), 'saved');
    expect(s.state.value.title, 'saved');
  });
}
