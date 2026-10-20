import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/application/settings/appearance_controller.dart';
import 'package:prism_browser/domain/browser/models.dart';

import '../helpers/pump_app.dart';

void main() {
  test('tabs: new, pin, duplicate, close keeps a valid active tab', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    final tabs = c.read(tabsProvider.notifier);
    final before = c.read(tabsProvider).tabs.length;

    final id = tabs.newTab();
    expect(c.read(tabsProvider).activeId, id);
    expect(c.read(tabsProvider).tabs.length, before + 1);

    tabs.togglePin('t2');
    expect(
      c.read(tabsProvider).tabs.firstWhere((t) => t.id == 't2').pinned,
      isTrue,
    );

    tabs.duplicate('t3');
    final s = c.read(tabsProvider);
    final i = s.tabs.indexWhere((t) => t.id == 't3');
    expect(s.tabs[i + 1].url, s.tabs[i].url);

    tabs.close(c.read(tabsProvider).activeId);
    final after = c.read(tabsProvider);
    expect(after.tabs.any((t) => t.id == after.activeId), isTrue);
  });

  test('closing the last tab opens a fresh start page', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    final tabs = c.read(tabsProvider.notifier);
    for (final t in [
      ...c.read(tabsProvider).tabs,
      ...c.read(tabsProvider).incognitoTabs,
    ]) {
      tabs.close(t.id);
    }
    final s = c.read(tabsProvider);
    expect(s.tabs, hasLength(1));
    expect(s.tabs.single.isStartPage, isTrue);
  });

  test('incognito tabs are separate and cleared together', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    final tabs = c.read(tabsProvider.notifier);
    tabs.newTab(incognito: true);
    expect(c.read(tabsProvider).active.incognito, isTrue);
    tabs.clearIncognito();
    expect(c.read(tabsProvider).incognitoTabs, isEmpty);
    expect(c.read(tabsProvider).active.incognito, isFalse);
  });

  test('privacy: manual toggle switches profile to custom', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    final p = c.read(privacyProvider.notifier);
    p.setProfile(PrivacyProfile.strict);
    expect(c.read(privacyProvider).antiFingerprinting, isTrue);
    p.update((s) => s.copyWith(blockAds: false));
    expect(c.read(privacyProvider).profile, PrivacyProfile.custom);
  });

  test('search engine choice persists', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    c.read(searchEngineProvider.notifier).set(SearchEngineId.brave);
    expect(
      c.read(sharedPreferencesProvider).getString('search.engine'),
      'brave',
    );
  });
}
