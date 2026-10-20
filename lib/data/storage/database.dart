import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Local SQLite database (drift): tabs, groups, history, bookmarks,
/// downloads. Never holds incognito data. Settings stay in
/// shared_preferences; secrets will use flutter_secure_storage (stage 5).
///
/// Regenerate after schema changes:
///   dart run build_runner build --delete-conflicting-outputs
@DriftDatabase(
  tables: [
    TabRows,
    TabGroupRows,
    SessionMeta,
    HistoryVisits,
    BookmarkFolderRows,
    BookmarkRows,
    DownloadRows,
  ],
)
class PrismDatabase extends _$PrismDatabase {
  PrismDatabase(super.e);

  /// The on-device database (background isolate, app support directory).
  factory PrismDatabase.open() => PrismDatabase(driftDatabase(name: 'prism'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

@DataClassName('TabRow')
class TabRows extends Table {
  @override
  String get tableName => 'tabs';

  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text().withDefault(const Constant(''))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get groupId => text().nullable()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TabGroupRow')
class TabGroupRows extends Table {
  @override
  String get tableName => 'tab_groups';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key/value facts about the saved session (active tab id).
class SessionMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('HistoryRow')
@TableIndex(name: 'history_visited_at', columns: {#visitedAt})
@TableIndex(name: 'history_url', columns: {#url})
class HistoryVisits extends Table {
  @override
  String get tableName => 'history';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get visitedAt => dateTime()();

  /// Lower-cased "title url", computed in Dart: SQLite's lower()/LIKE only
  /// fold ASCII, so Cyrillic searches must not rely on them.
  TextColumn get search => text().withDefault(const Constant(''))();
}

@DataClassName('BookmarkFolderRow')
class BookmarkFolderRows extends Table {
  @override
  String get tableName => 'bookmark_folders';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BookmarkRow')
@TableIndex(name: 'bookmarks_url', columns: {#url})
class BookmarkRows extends Table {
  @override
  String get tableName => 'bookmarks';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get folderId => text().nullable().references(
    BookmarkFolderRows,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DownloadRow')
class DownloadRows extends Table {
  @override
  String get tableName => 'downloads';

  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get fileName => text()();

  /// Where the file is (or is being) written.
  TextColumn get filePath => text()();

  /// Android: content:// URI of the copy in the public Downloads folder.
  TextColumn get contentUri => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get totalBytes => integer().withDefault(const Constant(-1))();
  IntColumn get receivedBytes => integer().withDefault(const Constant(0))();

  /// [DownloadState.name].
  TextColumn get state => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
