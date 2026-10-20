import 'package:flutter/foundation.dart';

import 'models.dart';

/// Persistence contracts. Implemented with drift in `data/storage`; the
/// application layer never sees SQL. Incognito data never reaches them.

/// The restorable browsing session (regular tabs only).
@immutable
class TabsSnapshot {
  const TabsSnapshot({
    required this.tabs,
    required this.groups,
    required this.activeId,
  });

  final List<BrowserTab> tabs;
  final List<TabGroup> groups;
  final String? activeId;
}

abstract interface class TabsRepository {
  /// Null on first launch (nothing saved yet).
  Future<TabsSnapshot?> load();

  /// Replaces the saved session in one transaction, so a crash leaves
  /// either the previous or the new session, never a mix.
  Future<void> save(TabsSnapshot snapshot);
}

abstract interface class HistoryRepository {
  /// Newest first; [query] matches title or URL (case-insensitive).
  Stream<List<HistoryEntry>> watch({String query = '', int limit = 500});

  /// Best matches for the omnibox: most visited and most recent first.
  Future<List<HistoryEntry>> suggest(String query, {int limit = 5});

  /// Returns the new entry id (for [updateTitle]).
  Future<String> addVisit(String url, String title, DateTime at);
  Future<void> updateTitle(String id, String title);
  Future<void> delete(String id);

  /// Deletes visits at or after [since]; null deletes everything.
  Future<void> clear({DateTime? since});
}

@immutable
class BookmarksData {
  const BookmarksData({required this.folders, required this.bookmarks});

  static const empty = BookmarksData(folders: [], bookmarks: []);

  final List<BookmarkFolder> folders;
  final List<Bookmark> bookmarks;
}

abstract interface class BookmarksRepository {
  Stream<BookmarksData> watch();

  Future<void> addBookmark(Bookmark bookmark);
  Future<void> updateBookmark(Bookmark bookmark);
  Future<void> deleteBookmark(String id);

  /// Removes every bookmark of [url] (the star toggles off).
  Future<void> deleteByUrl(String url);

  Future<void> addFolder(BookmarkFolder folder);
  Future<void> renameFolder(String id, String name);

  /// Bookmarks inside move to "Unsorted" (nothing is lost silently).
  Future<void> deleteFolder(String id);
}

/// Tab preview images (JPEG bytes), kept in the app cache.
abstract interface class ThumbnailStore {
  Future<Uint8List?> load(String tabId);
  Future<void> save(String tabId, Uint8List bytes);
  Future<void> delete(String tabId);

  /// Drops previews of tabs that no longer exist.
  Future<void> retainOnly(Set<String> tabIds);
}

abstract interface class DownloadsRepository {
  Stream<List<DownloadItem>> watch();
  Future<List<DownloadItem>> all();
  Future<void> upsert(DownloadItem item);
  Future<void> delete(String id);
}
