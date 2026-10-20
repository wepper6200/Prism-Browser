import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/downloads/download_io.dart';
import '../../data/storage/database.dart';
import '../../data/storage/drift_repositories.dart';
import '../../domain/browser/downloads.dart';
import '../../domain/browser/repositories.dart';

/// The SQLite database. Opened in main() (in parallel with settings) so the
/// saved tabs are ready for the first frame; tests use an in-memory one.
final databaseProvider = Provider<PrismDatabase>((ref) {
  final db = PrismDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final tabsRepositoryProvider = Provider<TabsRepository>(
  (ref) => DriftTabsRepository(ref.watch(databaseProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => DriftHistoryRepository(ref.watch(databaseProvider)),
);

final bookmarksRepositoryProvider = Provider<BookmarksRepository>(
  (ref) => DriftBookmarksRepository(ref.watch(databaseProvider)),
);

final downloadsRepositoryProvider = Provider<DownloadsRepository>(
  (ref) => DriftDownloadsRepository(ref.watch(databaseProvider)),
);

/// The session saved by the previous run (loaded in main()); null on a
/// first launch and in tests that start clean.
final initialTabsProvider = Provider<TabsSnapshot?>((ref) => null);

final downloadTransportProvider = Provider<DownloadTransport>(
  (ref) => HttpDownloadTransport(),
);

final platformFilesProvider = Provider<PlatformFiles>(
  (ref) => AppPlatformFiles(),
);
