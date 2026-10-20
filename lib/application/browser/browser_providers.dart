import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/engine/fake_engine.dart';
import '../../data/engine/inappwebview_engine.dart';
import '../../data/mock/mock_data.dart';
import '../../domain/browser/models.dart';
import '../../domain/engine/browser_engine.dart';
import '../../domain/engine/url_resolver.dart';
import '../settings/appearance_controller.dart';
import 'downloads_controller.dart';
import 'library_providers.dart';
import 'tabs_controller.dart';

export 'downloads_controller.dart';
export 'library_providers.dart';
export 'storage_providers.dart';
export 'tabs_controller.dart';
export 'thumbnails.dart';

/// Browser application state: engine sessions and navigation here; tabs,
/// library and downloads in the exported files (persisted with drift).

/// Demo fixtures (stage-2 mocks) for tests and showcase boards. Off in the
/// app: a clean install starts empty and offline.
final demoDataProvider = Provider<bool>((ref) => false);

enum PageSecurity { secure, insecure, internal }

/// Platform engine. Created lazily on first read (first page shown), never
/// during startup: a clean launch makes no network requests.
final engineProvider = Provider<BrowserEngine>((ref) {
  if (kIsWeb) return FakeEngine();
  return switch (defaultTargetPlatform) {
    // `--dart-define=PRISM_HC=true` switches to Hybrid Composition (spike
    // comparison / fallback for devices where TLHC misbehaves).
    TargetPlatform.android => AndroidEngine(
      hybridComposition: const bool.fromEnvironment('PRISM_HC'),
    ),
    TargetPlatform.windows => WindowsEngine(),
    _ => FakeEngine(),
  };
});

/// One live engine session per open tab, created on first use (lazy tabs).
/// Disposed by [TabsController.close] via invalidation.
final sessionProvider = Provider.family<TabSession, String>((ref, tabId) {
  final engine = ref.watch(engineProvider);
  final s = ref.read(tabsProvider);
  final tab = [...s.tabs, ...s.incognitoTabs].firstWhere(
    (t) => t.id == tabId,
    orElse: () => BrowserTab(id: tabId, title: '', url: ''),
  );
  final session = engine.createSession(
    tabId: tabId,
    incognito: tab.incognito,
    initialUrl: tab.url.isEmpty ? null : Uri.tryParse(tab.url),
    initialTitle: tab.title.isEmpty ? null : tab.title,
  );
  ref.onDispose(session.dispose);
  return session;
});

/// Live engine state of one tab; mirrors title/url back into [tabsProvider].
final sessionStateProvider =
    NotifierProvider.family<SessionStateNotifier, TabSessionState, String>(
      SessionStateNotifier.new,
      isAutoDispose: true,
    );

class SessionStateNotifier extends Notifier<TabSessionState> {
  SessionStateNotifier(this.tabId);

  final String tabId;

  @override
  TabSessionState build() {
    final session = ref.watch(sessionProvider(tabId));
    final recorder = ref.read(historyRecorderProvider);
    void listener() {
      final v = session.state.value;
      state = v;
      ref
          .read(tabsProvider.notifier)
          // A blank session is a start page: '' (never a stale URL).
          .updateMeta(tabId, title: v.title, url: v.url?.toString() ?? '');
      recorder.observe(tabId, incognito: session.incognito, s: v);
    }

    session.state.addListener(listener);
    ref.onDispose(() => session.state.removeListener(listener));
    return session.state.value;
  }
}

/// What the chrome shows for the active tab.
@immutable
class PageState {
  const PageState({required this.tab, required this.session});

  final BrowserTab tab;
  final TabSessionState session;

  Uri? get url => session.url;

  /// No navigation yet: the native start page is shown.
  bool get isBlank => session.isBlank;
  double get progress => session.progress;
  bool get loading => session.loading;
  int get blockedCount => session.blockedCount;
  bool get canGoBack => session.canGoBack;
  bool get canGoForward => session.canGoForward;
  String? get error => session.error;

  PageSecurity get security => switch (session.security) {
    PageSecurityLevel.secure => PageSecurity.secure,
    PageSecurityLevel.insecure => PageSecurity.insecure,
    PageSecurityLevel.internal => PageSecurity.internal,
  };
}

final pageStateProvider = Provider<PageState>((ref) {
  final tab = ref.watch(tabsProvider.select((s) => s.active));
  return PageState(tab: tab, session: ref.watch(sessionStateProvider(tab.id)));
});

/// Navigation commands for the active tab.
final browserActionsProvider = Provider<BrowserActions>(BrowserActions.new);

class BrowserActions {
  BrowserActions(this._ref);

  final Ref _ref;

  TabSession get _active =>
      _ref.read(sessionProvider(_ref.read(tabsProvider).activeId));

  /// Omnibox / speed-dial input: address or search query.
  Future<void> open(String input) async {
    final engine = _ref.read(activeSearchEngineProvider);
    final uri = UrlResolver.resolve(
      input,
      searchTemplate: engine.queryTemplate,
    );
    if (uri == null) return;
    await _ref.read(engineProvider).warmUp();
    await _active.load(uri);
  }

  Future<void> back() => _active.goBack();
  Future<void> forward() => _active.goForward();
  Future<void> reload() => _active.reload();
  Future<void> stop() => _active.stopLoading();
}

/// Injectable clock so tests and showcase boards render stable times.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final downloadsProvider =
    NotifierProvider<DownloadsController, List<DownloadItem>>(
      DownloadsController.new,
    );

final searchEngineProvider =
    NotifierProvider<SearchEngineController, SearchEngineId>(
      SearchEngineController.new,
    );

class SearchEngineController extends Notifier<SearchEngineId> {
  static const _key = 'search.engine';

  @override
  SearchEngineId build() {
    final name = ref.read(sharedPreferencesProvider).getString(_key);
    return SearchEngineId.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SearchEngineId.duckduckgo,
    );
  }

  void set(SearchEngineId id) {
    // "Custom" without a saved template would search nowhere.
    if (id == SearchEngineId.custom && ref.read(customSearchProvider) == null) {
      return;
    }
    state = id;
    ref.read(sharedPreferencesProvider).setString(_key, id.name).ignore();
  }
}

/// The user's own search engine ("Custom URL"), or null when not set.
final customSearchProvider =
    NotifierProvider<CustomSearchController, SearchEngine?>(
      CustomSearchController.new,
    );

class CustomSearchController extends Notifier<SearchEngine?> {
  static const _kName = 'search.custom.name';
  static const _kTemplate = 'search.custom.template';

  @override
  SearchEngine? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final template = prefs.getString(_kTemplate);
    if (template == null) return null;
    // Re-validate stored data (never trust persisted input blindly).
    final checked = CustomSearchTemplate.validate(template);
    if (!checked.isValid) return null;
    return SearchEngine.custom(
      name:
          prefs.getString(_kName) ??
          CustomSearchTemplate.suggestName(checked.template!),
      template: checked.template!,
    );
  }

  /// Validates, saves and selects the custom engine. Returns the error, if
  /// any, so the form can show it next to the field.
  CustomTemplateError? save({required String name, required String template}) {
    final checked = CustomSearchTemplate.validate(template);
    if (!checked.isValid) return checked.error;
    final cleanName = name.trim().isEmpty
        ? CustomSearchTemplate.suggestName(checked.template!)
        : name.trim();
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_kName, cleanName).ignore();
    prefs.setString(_kTemplate, checked.template!).ignore();
    state = SearchEngine.custom(name: cleanName, template: checked.template!);
    ref.read(searchEngineProvider.notifier).set(SearchEngineId.custom);
    return null;
  }

  /// Removes the custom engine; falls back to DuckDuckGo if it was active.
  void remove() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.remove(_kName).ignore();
    prefs.remove(_kTemplate).ignore();
    if (ref.read(searchEngineProvider) == SearchEngineId.custom) {
      ref.read(searchEngineProvider.notifier).set(SearchEngineId.duckduckgo);
    }
    state = null;
  }
}

/// The engine actually used for searches (built-in or custom).
final activeSearchEngineProvider = Provider<SearchEngine>((ref) {
  final id = ref.watch(searchEngineProvider);
  if (id == SearchEngineId.custom) {
    final custom = ref.watch(customSearchProvider);
    if (custom != null) return custom;
  }
  return SearchEngine.byId(
    id == SearchEngineId.custom ? SearchEngineId.duckduckgo : id,
  );
});

final privacyProvider = NotifierProvider<PrivacyController, PrivacySettings>(
  PrivacyController.new,
);

class PrivacyController extends Notifier<PrivacySettings> {
  @override
  PrivacySettings build() => const PrivacySettings();

  void setProfile(PrivacyProfile p) => state = PrivacySettings.forProfile(p);

  /// Any manual toggle switches the profile to "Custom".
  void update(PrivacySettings Function(PrivacySettings) change) =>
      state = change(state).copyWith(profile: PrivacyProfile.custom);
}

final sitePermissionsProvider = Provider<List<SitePermission>>(
  (ref) => ref.watch(demoDataProvider) ? MockData.permissions : const [],
);
