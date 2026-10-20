import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/search/suggest_client.dart';
import '../../domain/browser/models.dart';
import '../../domain/browser/repositories.dart';
import '../../domain/engine/browser_engine.dart';
import '../settings/appearance_controller.dart';
import 'browser_providers.dart';

// --- History ---------------------------------------------------------------

/// History matching [query] (newest first, up to 500 entries).
final historyQueryProvider = StreamProvider.autoDispose
    .family<List<HistoryEntry>, String>(
      (ref, query) => ref.watch(historyRepositoryProvider).watch(query: query),
    );

/// The whole recent history (start-page style consumers).
final historyProvider = Provider.autoDispose<List<HistoryEntry>>(
  (ref) => ref.watch(historyQueryProvider('')).value ?? const [],
);

enum ClearRange { hour, day, week, all }

final historyActionsProvider = Provider<HistoryActions>(HistoryActions.new);

class HistoryActions {
  HistoryActions(this._ref);

  final Ref _ref;

  HistoryRepository get _repo => _ref.read(historyRepositoryProvider);

  Future<void> delete(String id) => _repo.delete(id);

  Future<void> clear(ClearRange range) {
    final now = _ref.read(clockProvider)();
    return _repo.clear(
      since: switch (range) {
        ClearRange.hour => now.subtract(const Duration(hours: 1)),
        ClearRange.day => now.subtract(const Duration(days: 1)),
        ClearRange.week => now.subtract(const Duration(days: 7)),
        ClearRange.all => null,
      },
    );
  }
}

final historyRecorderProvider = Provider<HistoryRecorder>(HistoryRecorder.new);

/// Writes visits of regular tabs to history: one entry per finished page
/// load, its title updated when the page sets it later. Incognito tabs,
/// failed loads and non-web URLs are never recorded.
class HistoryRecorder {
  HistoryRecorder(this._ref);

  final Ref _ref;
  final _last = <String, ({String url, String title, Future<String> id})>{};

  void observe(
    String tabId, {
    required bool incognito,
    required TabSessionState s,
  }) {
    if (incognito || _ref.read(demoDataProvider)) return;
    final url = s.url;
    if (url == null || (url.scheme != 'https' && url.scheme != 'http')) return;
    if (s.loading || s.error != null) return;
    final key = url.toString();
    final last = _last[tabId];
    final repo = _ref.read(historyRepositoryProvider);
    if (last != null && last.url == key) {
      if (s.title.isNotEmpty && s.title != last.title) {
        _last[tabId] = (url: key, title: s.title, id: last.id);
        last.id.then((id) => repo.updateTitle(id, s.title)).ignore();
      }
      return;
    }
    final id = repo.addVisit(key, s.title, _ref.read(clockProvider)());
    _last[tabId] = (url: key, title: s.title, id: id);
  }

  void forget(String tabId) => _last.remove(tabId);
}

// --- Bookmarks -------------------------------------------------------------

final bookmarksDataProvider = StreamProvider<BookmarksData>(
  (ref) => ref.watch(bookmarksRepositoryProvider).watch(),
);

final bookmarksProvider = Provider<List<Bookmark>>(
  (ref) => ref.watch(bookmarksDataProvider).value?.bookmarks ?? const [],
);

final bookmarkFoldersProvider = Provider<List<BookmarkFolder>>(
  (ref) => ref.watch(bookmarksDataProvider).value?.folders ?? const [],
);

/// Whether [url] is bookmarked (the star in the toolbar).
final isBookmarkedProvider = Provider.family<bool, String>(
  (ref, url) =>
      url.isNotEmpty && ref.watch(bookmarksProvider).any((b) => b.url == url),
);

final bookmarkActionsProvider = Provider<BookmarkActions>(BookmarkActions.new);

class BookmarkActions {
  BookmarkActions(this._ref);

  final Ref _ref;
  int _seq = 0;

  BookmarksRepository get _repo => _ref.read(bookmarksRepositoryProvider);

  String _id(String prefix) =>
      '$prefix-${_ref.read(clockProvider)().microsecondsSinceEpoch.toRadixString(36)}-${_seq++}';

  /// Star: adds the page to "Unsorted", or removes it if already saved.
  /// Returns true when the page is now bookmarked.
  Future<bool> toggle(String url, String title) async {
    if (url.isEmpty) return false;
    if (_ref.read(isBookmarkedProvider(url))) {
      await _repo.deleteByUrl(url);
      return false;
    }
    await _repo.addBookmark(
      Bookmark(
        id: _id('bm'),
        title: title.trim().isEmpty ? url : title.trim(),
        url: url,
      ),
    );
    return true;
  }

  Future<void> update(Bookmark b) => _repo.updateBookmark(b);
  Future<void> delete(String id) => _repo.deleteBookmark(id);

  Future<String> addFolder(String name) async {
    final id = _id('fld');
    await _repo.addFolder(BookmarkFolder(id: id, name: name.trim()));
    return id;
  }

  Future<void> renameFolder(String id, String name) =>
      _repo.renameFolder(id, name.trim());
  Future<void> deleteFolder(String id) => _repo.deleteFolder(id);
}

// --- Omnibox ---------------------------------------------------------------

@immutable
class OmniboxSuggestion {
  const OmniboxSuggestion({required this.kind, required this.title, this.url});

  final SuggestionKind kind;
  final String title;
  final String? url;
}

enum SuggestionKind { search, history, bookmark }

/// Search suggestions from the engine (on by default; sent only after the
/// user starts typing, never from incognito).
final searchSuggestionsEnabledProvider =
    NotifierProvider<SearchSuggestionsController, bool>(
      SearchSuggestionsController.new,
    );

class SearchSuggestionsController extends Notifier<bool> {
  static const _key = 'search.suggestions';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? true;

  void set(bool v) {
    state = v;
    ref.read(sharedPreferencesProvider).setBool(_key, v).ignore();
  }
}

final suggestClientProvider = Provider<SuggestClient>(
  (ref) => HttpSuggestClient(),
);

/// Bookmarks and history matching what is typed (on the device only).
final localSuggestionsProvider = FutureProvider.autoDispose
    .family<List<OmniboxSuggestion>, String>((ref, query) async {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return const [];
      bool hit(String s) => s.toLowerCase().contains(q);
      final marks = ref
          .watch(bookmarksProvider)
          .where((b) => hit(b.title) || hit(b.url))
          .take(3)
          .toList();
      final seen = {for (final b in marks) b.url};
      final visits = await ref
          .read(historyRepositoryProvider)
          .suggest(q, limit: 5);
      return [
        for (final b in marks)
          OmniboxSuggestion(
            kind: SuggestionKind.bookmark,
            title: b.title,
            url: b.url,
          ),
        for (final h in visits.where((h) => !seen.contains(h.url)).take(4))
          OmniboxSuggestion(
            kind: SuggestionKind.history,
            title: h.title.isEmpty ? h.url : h.title,
            url: h.url,
          ),
      ];
    });

/// Engine suggestions for the (debounced) query; empty when disabled, in
/// incognito, or for an address.
final remoteSuggestionsProvider = FutureProvider.autoDispose
    .family<List<OmniboxSuggestion>, String>((ref, query) async {
      final q = query.trim();
      if (q.isEmpty || !ref.watch(searchSuggestionsEnabledProvider)) {
        return const [];
      }
      if (ref.watch(tabsProvider.select((s) => s.active.incognito))) {
        return const [];
      }
      final engine = ref.watch(activeSearchEngineProvider);
      final list = await ref.read(suggestClientProvider).suggest(engine.id, q);
      return [
        for (final s in list)
          if (s.toLowerCase() != q.toLowerCase())
            OmniboxSuggestion(kind: SuggestionKind.search, title: s),
      ];
    });
