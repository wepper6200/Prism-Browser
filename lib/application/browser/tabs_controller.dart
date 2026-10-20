import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_data.dart';
import '../../domain/browser/models.dart';
import '../../domain/browser/repositories.dart';
import 'browser_providers.dart';

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

  List<BrowserTab> get all => [...tabs, ...incognitoTabs];

  BrowserTab get active =>
      all.firstWhere((t) => t.id == activeId, orElse: () => tabs.first);

  TabsState copyWith({
    List<BrowserTab>? tabs,
    List<BrowserTab>? incognitoTabs,
    String? activeId,
    List<TabGroup>? groups,
  }) => TabsState(
    tabs: tabs ?? this.tabs,
    incognitoTabs: incognitoTabs ?? this.incognitoTabs,
    activeId: activeId ?? this.activeId,
    groups: groups ?? this.groups,
  );
}

final tabsProvider = NotifierProvider<TabsController, TabsState>(
  TabsController.new,
);

/// Open tabs, groups and the active tab. Regular tabs are saved to the
/// database after every change (crash-safe session restore); incognito
/// tabs live only in memory.
///
/// Lazy tabs: a tab's engine view exists only after it was shown
/// ([BrowserTab.loaded]). At most [maxLiveTabs] stay alive; older ones are
/// unloaded (and all inactive ones on memory pressure) and reload from
/// their URL when selected again.
class TabsController extends Notifier<TabsState> {
  int _seq = 0;
  final _recent = <String>[]; // most recently shown last
  Future<void>? _inFlight;
  bool _dirty = false;

  static int get maxLiveTabs =>
      defaultTargetPlatform == TargetPlatform.android ? 5 : 10;

  @override
  TabsState build() {
    _seq = DateTime.now().microsecondsSinceEpoch;
    if (ref.watch(demoDataProvider)) {
      return const TabsState(
        tabs: MockData.tabs,
        incognitoTabs: MockData.incognitoTabs,
        activeId: 't1',
        groups: MockData.groups,
      );
    }
    // Save on every change (not on the initial build: nothing changed).
    listenSelf((prev, next) {
      if (prev != null) _save();
    });
    final saved = ref.read(initialTabsProvider);
    if (saved == null || saved.tabs.isEmpty) {
      // Clean start: one native start page, no engine navigation.
      final id = _newId();
      return TabsState(
        tabs: [BrowserTab(id: id, title: '', url: '')],
        incognitoTabs: const [],
        activeId: id,
        groups: saved?.groups ?? const [],
      );
    }
    final activeId = saved.tabs.any((t) => t.id == saved.activeId)
        ? saved.activeId!
        : saved.tabs.last.id;
    _recent.add(activeId);
    return TabsState(
      tabs: [
        for (final t in saved.tabs)
          t.id == activeId ? t.copyWith(loaded: true) : t,
      ],
      incognitoTabs: const [],
      activeId: activeId,
      groups: saved.groups,
    );
  }

  String _newId() => 'tab-${(_seq++).toRadixString(36)}';

  /// Coalesced, timer-free persistence: one write in flight at a time,
  /// the latest state is written right after it.
  void _save() {
    if (_inFlight != null) {
      _dirty = true;
      return;
    }
    _inFlight = _write().whenComplete(() => _inFlight = null);
  }

  Future<void> _write() async {
    final repo = ref.read(tabsRepositoryProvider);
    do {
      _dirty = false;
      final s = state;
      await repo.save(
        TabsSnapshot(
          tabs: s.tabs,
          groups: s.groups,
          // An incognito tab is never the one restored.
          activeId: s.tabs.any((t) => t.id == s.activeId) ? s.activeId : null,
        ),
      );
    } while (_dirty && ref.mounted);
  }

  /// Completes when the latest state is on disk (app pause, tests).
  Future<void> flush() async {
    while (_inFlight != null) {
      await _inFlight;
    }
  }

  BrowserTab? _find(String id) {
    for (final t in state.all) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<BrowserTab> _map(
    List<BrowserTab> l,
    String id,
    BrowserTab Function(BrowserTab) f,
  ) => [for (final t in l) t.id == id ? f(t) : t];

  void _update(String id, BrowserTab Function(BrowserTab) f) =>
      state = state.copyWith(
        tabs: _map(state.tabs, id, f),
        incognitoTabs: _map(state.incognitoTabs, id, f),
      );

  void select(String id) {
    if (_find(id) == null) return;
    final prev = state.activeId;
    if (prev != id) {
      ref.read(thumbnailsProvider.notifier).capture(prev).ignore();
    }
    _recent
      ..remove(id)
      ..add(id);
    state = state.copyWith(activeId: id);
    _update(id, (t) => t.loaded ? t : t.copyWith(loaded: true));
    _enforceLimit();
  }

  String newTab({bool incognito = false, String url = '', String? groupId}) {
    final id = _newId();
    final tab = BrowserTab(
      id: id,
      title: '',
      url: url,
      incognito: incognito,
      groupId: incognito ? null : groupId,
    );
    final prev = state.activeId;
    ref.read(thumbnailsProvider.notifier).capture(prev).ignore();
    state = incognito
        ? state.copyWith(
            incognitoTabs: [...state.incognitoTabs, tab],
            activeId: id,
          )
        : state.copyWith(tabs: [...state.tabs, tab], activeId: id);
    _recent.add(id);
    _enforceLimit();
    return id;
  }

  void close(String id) {
    ref.invalidate(sessionProvider(id));
    ref.read(thumbnailsProvider.notifier).forget(id);
    _recent.remove(id);
    final tabs = state.tabs.where((t) => t.id != id).toList();
    final inc = state.incognitoTabs.where((t) => t.id != id).toList();
    if (tabs.isEmpty && inc.isEmpty) {
      final fresh = BrowserTab(id: _newId(), title: '', url: '');
      state = state.copyWith(
        tabs: [fresh],
        incognitoTabs: [],
        activeId: fresh.id,
      );
      return;
    }
    var active = state.activeId;
    if (active == id) {
      final wasIncognito = state.incognitoTabs.any((t) => t.id == id);
      // Stay in the same mode when possible.
      active = wasIncognito && inc.isNotEmpty
          ? inc.last.id
          : (tabs.isNotEmpty ? tabs.last.id : inc.last.id);
    }
    state = state.copyWith(tabs: tabs, incognitoTabs: inc);
    if (active != state.activeId) select(active);
  }

  void togglePin(String id) =>
      _update(id, (t) => t.copyWith(pinned: !t.pinned));

  void duplicate(String id) {
    final src = _find(id);
    if (src == null) return;
    final copy = BrowserTab(
      id: _newId(),
      title: src.title,
      url: src.url,
      groupId: src.groupId,
      incognito: src.incognito,
    );
    List<BrowserTab> insert(List<BrowserTab> l) {
      final i = l.indexWhere((t) => t.id == id);
      return i < 0 ? l : ([...l]..insert(i + 1, copy));
    }

    state = state.copyWith(
      tabs: insert(state.tabs),
      incognitoTabs: insert(state.incognitoTabs),
    );
    select(copy.id);
  }

  /// Closes every incognito tab: sessions, thumbnails and the incognito
  /// downloads list are dropped.
  void clearIncognito() {
    final thumbs = ref.read(thumbnailsProvider.notifier);
    for (final t in state.incognitoTabs) {
      ref.invalidate(sessionProvider(t.id));
      thumbs.forget(t.id);
      _recent.remove(t.id);
    }
    ref.read(downloadsProvider.notifier).forgetIncognito();
    final wasActive = state.active.incognito;
    state = state.copyWith(incognitoTabs: []);
    if (wasActive) select(state.tabs.last.id);
  }

  /// Engine reported a new title / URL for a tab.
  void updateMeta(String id, {required String title, String? url}) {
    final t = _find(id);
    if (t == null || (t.title == title && (url == null || t.url == url))) {
      return;
    }
    _update(id, (t) => t.copyWith(title: title, url: url));
  }

  // --- Lazy loading -------------------------------------------------------

  /// Frees a tab's engine view; it reloads from its URL when shown again.
  void unload(String id) {
    final t = _find(id);
    if (t == null || !t.loaded || id == state.activeId) return;
    final thumbs = ref.read(thumbnailsProvider.notifier);
    thumbs.capture(id).whenComplete(() {
      ref.invalidate(sessionProvider(id));
    }).ignore();
    _recent.remove(id);
    _update(id, (t) => t.copyWith(loaded: false));
  }

  /// Memory pressure: keep only the visible tab alive.
  void unloadInactive() {
    for (final t in state.all) {
      if (t.loaded && t.id != state.activeId) unload(t.id);
    }
  }

  void _enforceLimit() {
    final live = state.all.where((t) => t.loaded).map((t) => t.id).toSet();
    final order = [
      // Never shown since restore, then least recently used.
      ...live.where((id) => !_recent.contains(id)),
      ..._recent.where(live.contains),
    ];
    var excess = live.length - maxLiveTabs;
    for (final id in order) {
      if (excess <= 0) break;
      if (id == state.activeId) continue;
      unload(id);
      excess--;
    }
  }

  // --- Groups -------------------------------------------------------------

  String createGroup(String name, int color, {String? withTab}) {
    final id = 'grp-${(_seq++).toRadixString(36)}';
    state = state.copyWith(
      groups: [
        ...state.groups,
        TabGroup(id: id, name: name.trim(), color: color),
      ],
    );
    if (withTab != null) setGroup(withTab, id);
    return id;
  }

  void renameGroup(String id, String name) => state = state.copyWith(
    groups: [
      for (final g in state.groups)
        g.id == id ? TabGroup(id: g.id, name: name.trim(), color: g.color) : g,
    ],
  );

  void recolorGroup(String id, int color) => state = state.copyWith(
    groups: [
      for (final g in state.groups)
        g.id == id ? TabGroup(id: g.id, name: g.name, color: color) : g,
    ],
  );

  /// Removes the group; its tabs stay open, ungrouped.
  void deleteGroup(String id) => state = state.copyWith(
    groups: state.groups.where((g) => g.id != id).toList(),
    tabs: [
      for (final t in state.tabs)
        t.groupId == id ? t.copyWith(clearGroup: true) : t,
    ],
  );

  void setGroup(String tabId, String? groupId) => _update(
    tabId,
    (t) => t.incognito
        ? t
        : (groupId == null
              ? t.copyWith(clearGroup: true)
              : t.copyWith(groupId: groupId)),
  );
}
