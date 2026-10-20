import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('custom search engine: validate, save, search with it', (
    tester,
  ) async {
    setSurface(tester, const Size(412, 915), const Locale('ru'));
    final engine = FakeEngine();
    final c = await makeContainer(
      settings: const AppearanceSettings(onboardingDone: true),
      location: '/settings/search',
      engine: engine,
      demo: false,
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const PrismApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Свой URL'));
    await tester.pumpAndSettle();
    expect(find.text('Своя поисковая система'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'SearXNG');
    await tester.enterText(fields.at(1), 'searx.example.org/search?q=');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(
      find.text('Добавьте %s в то место, куда подставляется запрос'),
      findsOneWidget,
    );
    expect(c.read(customSearchProvider), isNull);

    await tester.enterText(fields.at(1), 'searx.example.org/search?q=%s');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(c.read(searchEngineProvider), SearchEngineId.custom);
    expect(c.read(activeSearchEngineProvider).name, 'SearXNG');
    expect(find.text('SearXNG'), findsOneWidget);

    await c.read(browserActionsProvider).open('призма');
    expect(
      engine.loadLog.single,
      'https://searx.example.org/search?q=${Uri.encodeQueryComponent('призма')}',
    );

    // Removing the custom engine falls back to Prism Search.
    c.read(customSearchProvider.notifier).remove();
    expect(c.read(activeSearchEngineProvider).id, SearchEngineId.prism);
  });
}
