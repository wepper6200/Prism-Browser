import 'package:drift/drift.dart';

import '../../domain/browser/models.dart';
import '../../domain/browser/repositories.dart';
import 'database.dart';

class DriftTabsRepository implements TabsRepository {
  DriftTabsRepository(this._db);

  final PrismDatabase _db;
  static const _activeKey = 'active_tab';

  @override
  Future<TabsSnapshot?> load() async {
    final rows = await (_db.select(
      _db.tabRows,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final groups = await (_db.select(
      _db.tabGroupRows,
    )..orderBy([(g) => OrderingTerm.asc(g.position)])).get();
    final active = await (_db.select(
      _db.sessionMeta,
    )..where((m) => m.key.equals(_activeKey))).getSingleOrNull();
    if (rows.isEmpty && active == null) return null;
    return TabsSnapshot(
      tabs: [
        for (final r in rows)
          BrowserTab(
            id: r.id,
            title: r.title,
            url: r.url,
            pinned: r.pinned,
            groupId: r.groupId,
            // Restored tabs are cold: the engine view is created on demand.
            loaded: false,
          ),
      ],
      groups: [
        for (final g in groups)
          TabGroup(id: g.id, name: g.name, color: g.color),
      ],
      activeId: active?.value,
    );
  }

  @override
  Future<void> save(TabsSnapshot snapshot) => _db.transaction(() async {
    await _db.delete(_db.tabRows).go();
    await _db.delete(_db.tabGroupRows).go();
    await _db.batch((b) {
      b.insertAll(_db.tabRows, [
        for (final (i, t) in snapshot.tabs.indexed)
          if (!t.incognito)
            TabRowsCompanion.insert(
              id: t.id,
              title: Value(t.title),
              url: Value(t.url),
              pinned: Value(t.pinned),
              groupId: Value(t.groupId),
              position: i,
            ),
      ]);
      b.insertAll(_db.tabGroupRows, [
        for (final (i, g) in snapshot.groups.indexed)
          TabGroupRowsCompanion.insert(
            id: g.id,
            name: g.name,
            color: g.color,
            position: i,
          ),
      ]);
    });
    final active = snapshot.activeId;
    if (active == null) {
      await (_db.delete(
        _db.sessionMeta,
      )..where((m) => m.key.equals(_activeKey))).go();
    } else {
      await _db
          .into(_db.sessionMeta)
          .insertOnConflictUpdate(
            SessionMetaCompanion.insert(key: _activeKey, value: active),
          );
    }
  });
}

class DriftHistoryRepository implements HistoryRepository {
  DriftHistoryRepository(this._db);

  final PrismDatabase _db;

  /// What history search matches against (decoded URL, so Cyrillic paths
  /// match too).
  static String searchText(String url, String title) {
    var u = url;
    try {
      u = Uri.decodeFull(url);
    } on ArgumentError {
      // Keep the raw URL.
    }
    return '$title $u'.toLowerCase();
  }

  static HistoryEntry _entry(HistoryRow r) => HistoryEntry(
    id: '${r.id}',
    title: r.title,
    url: r.url,
    visitedAt: r.visitedAt,
  );

  /// LIKE pattern with the user's text escaped (`%` and `_` are literal).
  static String _like(String q) =>
      '%${q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';

  Expression<bool> _matches(String q) {
    // Every word must appear (in any order), case-insensitively in any
    // script: [HistoryVisits.search] is lower-cased by Dart.
    final h = _db.historyVisits;
    Expression<bool> all = const Constant(true);
    for (final w in q.toLowerCase().split(RegExp(r'\s+'))) {
      if (w.isEmpty) continue;
      all = all & h.search.like(_like(w), escapeChar: r'\');
    }
    return all;
  }

  @override
  Stream<List<HistoryEntry>> watch({String query = '', int limit = 500}) {
    final s = _db.select(_db.historyVisits);
    final q = query.trim();
    if (q.isNotEmpty) s.where((_) => _matches(q));
    s
      ..orderBy([
        (h) => OrderingTerm.desc(h.visitedAt),
        (h) => OrderingTerm.desc(h.id),
      ])
      ..limit(limit);
    return s.watch().map((rows) => rows.map(_entry).toList());
  }

  @override
  Future<List<HistoryEntry>> suggest(String query, {int limit = 5}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final h = _db.historyVisits;
    final visits = h.id.count();
    final last = h.visitedAt.max();
    final rows =
        await (_db.selectOnly(h)
              ..addColumns([h.url, h.title, visits, last, h.id.max()])
              ..where(_matches(q))
              ..groupBy([h.url])
              ..orderBy([OrderingTerm.desc(visits), OrderingTerm.desc(last)])
              ..limit(limit))
            .get();
    return [
      for (final r in rows)
        HistoryEntry(
          id: '${r.read(h.id.max())}',
          title: r.read(h.title) ?? '',
          url: r.read(h.url)!,
          visitedAt: r.read(last)!,
        ),
    ];
  }

  @override
  Future<String> addVisit(String url, String title, DateTime at) async {
    final id = await _db
        .into(_db.historyVisits)
        .insert(
          HistoryVisitsCompanion.insert(
            url: url,
            title: Value(title),
            visitedAt: at,
            search: Value(searchText(url, title)),
          ),
        );
    return '$id';
  }

  @override
  Future<void> updateTitle(String id, String title) async {
    final n = int.tryParse(id);
    if (n == null) return;
    final row = await (_db.select(
      _db.historyVisits,
    )..where((h) => h.id.equals(n))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.historyVisits)..where((h) => h.id.equals(n))).write(
      HistoryVisitsCompanion(
        title: Value(title),
        search: Value(searchText(row.url, title)),
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    final n = int.tryParse(id);
    if (n == null) return;
    await (_db.delete(_db.historyVisits)..where((h) => h.id.equals(n))).go();
  }

  @override
  Future<void> clear({DateTime? since}) async {
    final d = _db.delete(_db.historyVisits);
    if (since != null) d.where((h) => h.visitedAt.isBiggerOrEqualValue(since));
    await d.go();
  }
}

class DriftBookmarksRepository implements BookmarksRepository {
  DriftBookmarksRepository(this._db);

  final PrismDatabase _db;

  @override
  Stream<BookmarksData> watch() {
    // One trigger for both tables, then one consistent read of both.
    final trigger = _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.bookmarkFolderRows, _db.bookmarkRows},
        )
        .watch();
    return trigger.asyncMap((_) async {
      final f = await (_db.select(
        _db.bookmarkFolderRows,
      )..orderBy([(f) => OrderingTerm.asc(f.name)])).get();
      final b = await (_db.select(
        _db.bookmarkRows,
      )..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).get();
      return BookmarksData(
        folders: [
          for (final r in f)
            BookmarkFolder(id: r.id, name: r.name, parentId: r.parentId),
        ],
        bookmarks: [
          for (final r in b)
            Bookmark(
              id: r.id,
              title: r.title,
              url: r.url,
              folderId: r.folderId,
            ),
        ],
      );
    });
  }

  @override
  Future<void> addBookmark(Bookmark b) => _db
      .into(_db.bookmarkRows)
      .insert(
        BookmarkRowsCompanion.insert(
          id: b.id,
          title: b.title,
          url: b.url,
          folderId: Value(b.folderId),
          createdAt: DateTime.now(),
        ),
      );

  @override
  Future<void> updateBookmark(Bookmark b) async {
    await (_db.update(_db.bookmarkRows)..where((r) => r.id.equals(b.id))).write(
      BookmarkRowsCompanion(
        title: Value(b.title),
        url: Value(b.url),
        folderId: Value(b.folderId),
      ),
    );
  }

  @override
  Future<void> deleteBookmark(String id) async {
    await (_db.delete(_db.bookmarkRows)..where((r) => r.id.equals(id))).go();
  }

  @override
  Future<void> deleteByUrl(String url) async {
    await (_db.delete(_db.bookmarkRows)..where((r) => r.url.equals(url))).go();
  }

  @override
  Future<void> addFolder(BookmarkFolder f) => _db
      .into(_db.bookmarkFolderRows)
      .insert(
        BookmarkFolderRowsCompanion.insert(
          id: f.id,
          name: f.name,
          parentId: Value(f.parentId),
          createdAt: DateTime.now(),
        ),
      );

  @override
  Future<void> renameFolder(String id, String name) async {
    await (_db.update(_db.bookmarkFolderRows)..where((f) => f.id.equals(id)))
        .write(BookmarkFolderRowsCompanion(name: Value(name)));
  }

  @override
  Future<void> deleteFolder(String id) => _db.transaction(() async {
    // Explicit (not only the FK action): works even if foreign keys are
    // off on some SQLite build.
    await (_db.update(_db.bookmarkRows)..where((b) => b.folderId.equals(id)))
        .write(const BookmarkRowsCompanion(folderId: Value(null)));
    await (_db.delete(
      _db.bookmarkFolderRows,
    )..where((f) => f.id.equals(id))).go();
  });
}

class DriftDownloadsRepository implements DownloadsRepository {
  DriftDownloadsRepository(this._db);

  final PrismDatabase _db;

  static DownloadItem _item(DownloadRow r) => DownloadItem(
    id: r.id,
    fileName: r.fileName,
    url: r.url,
    totalBytes: r.totalBytes,
    receivedBytes: r.receivedBytes,
    state: DownloadState.values.firstWhere(
      (s) => s.name == r.state,
      orElse: () => DownloadState.failed,
    ),
    filePath: r.filePath,
    contentUri: r.contentUri,
    mimeType: r.mimeType,
    createdAt: r.createdAt,
  );

  SimpleSelectStatement<$DownloadRowsTable, DownloadRow> get _ordered =>
      _db.select(_db.downloadRows)
        ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]);

  @override
  Stream<List<DownloadItem>> watch() =>
      _ordered.watch().map((rows) => rows.map(_item).toList());

  @override
  Future<List<DownloadItem>> all() async =>
      (await _ordered.get()).map(_item).toList();

  @override
  Future<void> upsert(DownloadItem d) async {
    if (d.incognito) return;
    await _db
        .into(_db.downloadRows)
        .insertOnConflictUpdate(
          DownloadRowsCompanion.insert(
            id: d.id,
            url: d.url,
            fileName: d.fileName,
            filePath: d.filePath,
            contentUri: Value(d.contentUri),
            mimeType: Value(d.mimeType),
            totalBytes: Value(d.totalBytes),
            receivedBytes: Value(d.receivedBytes),
            state: d.state.name,
            createdAt: d.createdAt ?? DateTime.now(),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.downloadRows)..where((d) => d.id.equals(id))).go();
  }
}
