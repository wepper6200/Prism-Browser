import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/application/browser/browser_providers.dart';
import 'package:prism_browser/application/settings/appearance_controller.dart';
import 'package:prism_browser/data/engine/fake_engine.dart';
import 'package:prism_browser/data/mock/mock_data.dart';
import 'package:prism_browser/data/storage/database.dart';
import 'package:prism_browser/data/storage/drift_repositories.dart';
import 'package:prism_browser/data/storage/thumbnail_store.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/browser/repositories.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';
import 'package:prism_browser/presentation/app/router.dart';
import 'package:prism_browser/presentation/gallery/design_gallery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fakes.dart';

export 'fakes.dart';

Future<SharedPreferencesWithCache> freshPrefs() async {
  // Every test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
}

/// Fixed "now" so history groups and times render identically every run.
final fixedNow = DateTime(2026, 10, 20, 14, 30);

/// Creates a container with fresh prefs, the given appearance, a fixed
/// clock and the router starting at [location].
Future<ProviderContainer> makeContainer({
  AppearanceSettings settings = const AppearanceSettings(),
  String location = '/',
  double progress = 1,
  FakeEngine? engine,
  bool demo = true,
  PrismDatabase? db,
  TabsSnapshot? session,
  FakeTransport? transport,
  FakePlatformFiles? files,
  FakeSuggestClient? suggest,
}) async {
  final prefs = await freshPrefs();
  final database = db ?? PrismDatabase(NativeDatabase.memory());
  if (demo && db == null) await seedDemo(database);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      initialLocationProvider.overrideWithValue(location),
      clockProvider.overrideWithValue(() => fixedNow),
      // Stage-2 fixtures (tabs, history, ...) for deterministic screens.
      demoDataProvider.overrideWithValue(demo),
      // Platform views can't run in widget tests: deterministic engine.
      engineProvider.overrideWithValue(
        engine ?? FakeEngine(progress: progress),
      ),
      // Storage, network and files: in memory and offline.
      databaseProvider.overrideWithValue(database),
      initialTabsProvider.overrideWithValue(session),
      thumbnailStoreProvider.overrideWithValue(MemoryThumbnailStore()),
      downloadTransportProvider.overrideWithValue(transport ?? FakeTransport()),
      platformFilesProvider.overrideWithValue(
        files ?? FakePlatformFiles(Directory.systemTemp.path),
      ),
      suggestClientProvider.overrideWithValue(suggest ?? FakeSuggestClient()),
    ],
  );
  container.read(appearanceProvider.notifier).update((_) => settings);
  return container;
}

/// Stage-2 fixtures written to the database, as the screens read them.
Future<void> seedDemo(PrismDatabase db) async {
  final bookmarks = DriftBookmarksRepository(db);
  for (final f in MockData.folders) {
    await bookmarks.addFolder(f);
  }
  for (final b in MockData.bookmarks) {
    await bookmarks.addBookmark(b);
  }
  final history = DriftHistoryRepository(db);
  for (final h in MockData.history(fixedNow).reversed) {
    await history.addVisit(h.url, h.title, h.visitedAt);
  }
  final downloads = DriftDownloadsRepository(db);
  for (final (i, d) in MockData.downloads.indexed) {
    await downloads.upsert(
      DownloadItem(
        id: d.id,
        fileName: d.fileName,
        url: d.url,
        totalBytes: d.totalBytes,
        receivedBytes: d.receivedBytes,
        state: d.state,
        filePath: d.fileName,
        createdAt: fixedNow.subtract(Duration(minutes: i)),
      ),
    );
  }
}

void setSurface(WidgetTester tester, Size size, Locale locale) {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

/// Pumps the real [PrismApp] showing [home] (design gallery by default).
Future<ProviderContainer> pumpPrismApp(
  WidgetTester tester, {
  AppearanceSettings settings = const AppearanceSettings(),
  Size size = const Size(412, 915),
  Locale locale = const Locale('ru'),
  Widget home = const DesignGalleryScreen(),
}) async {
  setSurface(tester, size, locale);
  final container = await makeContainer(settings: settings);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: PrismApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Pumps the routed app at [location] (onboarding done unless overridden).
Future<ProviderContainer> pumpRoutedApp(
  WidgetTester tester, {
  String location = '/',
  AppearanceSettings settings = const AppearanceSettings(onboardingDone: true),
  Size size = const Size(412, 915),
  Locale locale = const Locale('ru'),
}) async {
  setSurface(tester, size, locale);
  final container = await makeContainer(settings: settings, location: location);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PrismApp()),
  );
  await tester.pumpAndSettle();
  return container;
}
