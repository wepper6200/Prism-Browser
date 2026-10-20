import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/browser/browser_providers.dart';
import 'application/settings/appearance_controller.dart';
import 'data/storage/database.dart';
import 'data/storage/drift_repositories.dart';
import 'domain/browser/repositories.dart';
import 'presentation/app/prism_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Before the first frame: settings (the right style is painted at once)
  // and the saved tabs (one small query; the database runs in a background
  // isolate). Both in parallel. The web engine, history and filter lists
  // stay lazy.
  final db = PrismDatabase.open();
  final (prefs, session) = await (
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    ),
    _loadSession(db),
  ).wait;
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        initialTabsProvider.overrideWithValue(session),
      ],
      child: const PrismApp(),
    ),
  );
}

/// A damaged database must not keep the browser from starting: start
/// with a fresh session instead.
Future<TabsSnapshot?> _loadSession(PrismDatabase db) async {
  try {
    return await DriftTabsRepository(db).load();
  } on Object {
    return null;
  }
}
