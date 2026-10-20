import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/thumbnail_store.dart';
import '../../domain/browser/repositories.dart';
import 'browser_providers.dart';

final thumbnailStoreProvider = Provider<ThumbnailStore>(
  (ref) => FileThumbnailStore(),
);

final thumbnailsProvider =
    NotifierProvider<ThumbnailsController, Map<String, Uint8List>>(
      ThumbnailsController.new,
    );

/// Tab previews for the tab switcher. Captured when a tab is left or
/// unloaded; regular tabs are cached on disk so restored sessions show
/// them, incognito previews stay in memory.
class ThumbnailsController extends Notifier<Map<String, Uint8List>> {
  @override
  Map<String, Uint8List> build() {
    _restore().ignore();
    return const {};
  }

  Future<void> _restore() async {
    final store = ref.read(thumbnailStoreProvider);
    final tabs = ref.read(tabsProvider).tabs;
    await store.retainOnly({for (final t in tabs) t.id});
    for (final t in tabs) {
      if (state.containsKey(t.id)) continue;
      final bytes = await store.load(t.id);
      if (bytes != null && ref.mounted) state = {...state, t.id: bytes};
    }
  }

  /// Screenshot of a live tab (nothing for start pages or unloaded tabs).
  Future<void> capture(String tabId) async {
    final tab = ref
        .read(tabsProvider)
        .all
        .where((t) => t.id == tabId)
        .firstOrNull;
    if (tab == null || !tab.loaded || tab.isStartPage) return;
    final Uint8List? bytes;
    try {
      bytes = await ref.read(sessionProvider(tabId)).captureThumbnail();
    } on Object {
      return;
    }
    if (bytes == null || !ref.mounted) return;
    state = {...state, tabId: bytes};
    if (!tab.incognito) {
      await ref.read(thumbnailStoreProvider).save(tabId, bytes);
    }
  }

  void forget(String tabId) {
    if (state.containsKey(tabId)) {
      state = {...state}..remove(tabId);
    }
    ref.read(thumbnailStoreProvider).delete(tabId).ignore();
  }
}
