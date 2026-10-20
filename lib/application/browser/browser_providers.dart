import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/engine/fake_engine.dart';
import '../../data/engine/inappwebview_engine.dart';
import '../../data/mock/mock_data.dart';
import '../../domain/browser/models.dart';
import '../../domain/engine/browser_engine.dart';
import '../../domain/engine/url_resolver.dart';
import '../settings/appearance_controller.dart';

/// Application state. Tabs/library are still backed by [MockData] (drift
/// in stage 4); pages come from the real engine since stage 3.

@immutable
class TabsState {
  const TabsState({
    required this.tabs,
    required this.incognitoTabs,
    required this.activeId,
    required this.groups,
  });

  final List<BrowserTab> tabs;
  final List<BrowserTab> incognitoTabs;
  final String activeId;
  final List<TabGroup> groups;

  BrowserTab get active => [
    ...tabs,
    ...incognitoTabs,
  ].firstWhere((t) => t.id == activeId, orElse: () => tabs.first);

  TabsState copyWith({
    List<BrowserTab>? tabs,
    List<BrowserTab>? incognitoTabs,
    String? activeId,
  }) => TabsState(
    tabs: tabs ?? this.tabs,
    incognitoTabs: incognitoTabs ?? this.incognitoTabs,
    activeId: activeId ?? this.activeId,
    groups: groups,
  );
}

/// Demo fixtures (stage-2 mocks) for tests and showcase boards. Off in the
/// app: a clean install starts empty and offline.
final demoDataProvider = Provider<bool>((ref) => false);

final tabsProvider = NotifierProvider<TabsController, TabsState>(
  TabsController.new,
);

class TabsController extends Notifier<TabsState> {
  int _seq = 100;

  @override
  TabsState build() {
    if (ref.watch(demoDataProvider)) {
      return const TabsState(
        tabs: MockData.tabs,
        incognitoTabs: MockData.incognitoTabs,
        activeId: 't1',
        groups: MockData.groups,
      );
    }
    // Clean start: one native start page, no engine navigation, no
    // network. Session restore arrives with persistence (stage 4).
    return const TabsState(
      tabs: [BrowserTab(id: 'n0', title: '', url: '')],
      incognitoTabs: [],
      activeId: 'n0',
      groups: [],
    );
  }

  void select(String id) => state = state.copyWith(activeId: id);

  String newTab({bool incognito = false}) {
    final id = 'n${_seq++}';
    final tab = BrowserTab(id: id, title: '', url: '', incognito: incognito);
    state = incognito
        ? state.copyWith(
            incognitoTabs: [...state.incognitoTabs, tab],
            activeId: id,
          )
        : state.copyWith(tabs: [...state.tabs, tab], activeId: id);
    return id;
  }

  void close(String id) {
    ref.invalidate(sessionProvider(id));
    final tabs = state.tabs.where((t) => t.id != id).toList();
    final inc = state.incognitoTabs.where((t) => t.id != id).toList();
    var active = state.activeId;
    if (active == id) {
      active = tabs.isNotEmpty
          ? tabs.last.id
          : (inc.isNotEmpty ? inc.last.id : '');
    }
    if (tabs.isEmpty && inc.isEmpty) {
      final fresh = BrowserTab(id: 'n${_seq++}', title: '', url: '');
      state = state.copyWith(
        tabs: [fresh],
        incognitoTabs: [],
        activeId: fresh.id,
      );
      return;
    }
    state = state.copyWith(tabs: tabs, incognitoTabs: inc, activeId: active);
  }

  void togglePin(String id) => state = state.copyWith(
    tabs: [
      for (final t in state.tabs)
        t.id == id ? t.copyWith(pinned: !t.pinned) : t,
    ],
  );

  void duplicate(String id) {
    final src = state.tabs.firstWhere((t) => t.id == id);
    final copy = BrowserTab(
      id: 'n${_seq++}',
      title: src.title,
      url: src.url,
      groupId: src.groupId,
    );
    final i = state.tabs.indexOf(src);
    state = state.copyWith(
      tabs: [...state.tabs]..insert(i + 1, copy),
      activeId: copy.id,
    );
  }

  void clearIncognito() {
    final tabs = state.tabs;
    for (final t in state.incognitoTabs) {
      ref.invalidate(sessionProvider(t.id));
    }
    state = state.copyWith(
      incognitoTabs: [],
      activeId: state.active.incognito ? tabs.last.id : state.activeId,
    );
  }

  /// Engine reported a new title / URL for a tab.
  void updateMeta(String id, {required String title, String? url}) {
    BrowserTab upd(BrowserTab t) =>
        t.id == id && (t.title != title || (url != null && t.url != url))
        ? t.copyWith(title: title, url: url)
        : t;
    final tabs = state.tabs.map(upd).toList();
    final inc = state.incognitoTabs.map(upd).toList();
    if (!listEquals(tabs, state.tabs) ||
        !listEquals(inc, state.incognitoTabs)) {
      state = state.copyWith(tabs: tabs, incognitoTabs: inc);
    }
  }
}

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
    void listener() {
      final v = session.state.value;
      state = v;
      ref
          .read(tabsProvider.notifier)
          .updateMeta(tabId, title: v.title, url: v.url?.toString());
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
    final engine = SearchEngine.byId(_ref.read(searchEngineProvider));
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

final bookmarksProvider = Provider<List<Bookmark>>(
  (ref) => ref.watch(demoDataProvider) ? MockData.bookmarks : const [],
);
final bookmarkFoldersProvider = Provider<List<BookmarkFolder>>(
  (ref) => ref.watch(demoDataProvider) ? MockData.folders : const [],
);

/// Injectable clock so tests and showcase boards render stable times.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final historyProvider = Provider<List<HistoryEntry>>(
  (ref) => ref.watch(demoDataProvider)
      ? MockData.history(ref.watch(clockProvider)())
      : const [],
);

final downloadsProvider =
    NotifierProvider<DownloadsController, List<DownloadItem>>(
      DownloadsController.new,
    );

class DownloadsController extends Notifier<List<DownloadItem>> {
  @override
  List<DownloadItem> build() =>
      ref.watch(demoDataProvider) ? MockData.downloads : const [];

  void toggle(String id) => state = [
    for (final d in state)
      if (d.id != id)
        d
      else
        d.copyWith(
          state: d.state == DownloadState.running
              ? DownloadState.paused
              : DownloadState.running,
        ),
  ];
}

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
    state = id;
    ref.read(sharedPreferencesProvider).setString(_key, id.name).ignore();
  }
}

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

/// Omnibox suggestions from history, bookmarks and (mock) search engine.
@immutable
class OmniboxSuggestion {
  const OmniboxSuggestion({required this.kind, required this.title, this.url});

  final SuggestionKind kind;
  final String title;
  final String? url;
}

enum SuggestionKind { search, history, bookmark }

final omniboxSuggestionsProvider =
    Provider.family<List<OmniboxSuggestion>, String>((ref, query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return const [];
      bool hit(String s) => s.toLowerCase().contains(q);
      return [
        // Search suggestions only after the user typed something.
        for (final s in MockData.searchSuggestions.where(hit).take(3))
          OmniboxSuggestion(kind: SuggestionKind.search, title: s),
        for (final b
            in ref
                .watch(bookmarksProvider)
                .where((b) => hit(b.title) || hit(b.url)))
          OmniboxSuggestion(
            kind: SuggestionKind.bookmark,
            title: b.title,
            url: b.url,
          ),
        for (final h
            in ref
                .watch(historyProvider)
                .where((h) => hit(h.title) || hit(h.url))
                .take(3))
          OmniboxSuggestion(
            kind: SuggestionKind.history,
            title: h.title,
            url: h.url,
          ),
      ];
    });
