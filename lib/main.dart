import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/settings/appearance_controller.dart';
import 'presentation/app/prism_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only settings are loaded before the first frame (a few KB, one file
  // read) so the right style is painted immediately. Everything heavier
  // (web engine, filter lists, database) is initialised lazily later.
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PrismApp(),
    ),
  );
}
