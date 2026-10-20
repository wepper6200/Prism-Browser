import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/settings/appearance_controller.dart';
import '../browser/browser_screen.dart';
import '../gallery/design_gallery_screen.dart';
import '../library/bookmarks_screen.dart';
import '../library/downloads_screen.dart';
import '../library/history_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/appearance_screen.dart';
import '../settings/permissions_screen.dart';
import '../settings/privacy_screen.dart';
import '../settings/search_engine_screen.dart';
import '../settings/settings_screen.dart';
import '../tabs/tab_switcher_screen.dart';

/// Every key screen has a URL (deep links, tests, showcase boards).
/// `/?panel=omnibox|menu|privacy|find` opens a browser panel on arrival.
GoRouter createRouter(Ref ref, {String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  redirect: (context, state) {
    final done = ref.read(appearanceProvider).onboardingDone;
    final atOnboarding = state.matchedLocation == '/onboarding';
    if (!done && !atOnboarding) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BrowserScreen(
        initialPanel: BrowserPanel.fromName(state.uri.queryParameters['panel']),
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/tabs',
      builder: (context, state) => TabSwitcherScreen(
        incognito: state.uri.queryParameters['incognito'] == '1',
      ),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/downloads',
      builder: (context, state) => const DownloadsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'appearance',
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) => const PrivacyScreen(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => const SearchEngineScreen(),
        ),
        GoRoute(
          path: 'permissions',
          builder: (context, state) => const PermissionsScreen(),
        ),
        GoRoute(
          path: 'design',
          builder: (context, state) => const DesignGalleryScreen(),
        ),
      ],
    ),
  ],
);

/// Overridable in tests / showcase to start on a given screen.
final initialLocationProvider = Provider<String>((ref) => '/');

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter(
    ref,
    initialLocation: ref.read(initialLocationProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});
