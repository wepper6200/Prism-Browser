import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/engine/browser_engine.dart';
import '../../domain/search/prism_search.dart';

/// A tab session that layers native pages (Prism Search results, the start
/// page) over the web engine's own back/forward list, so Back behaves like
/// one history:
///
///   start page → Prism Search "q" → result → (Back) "q" → (Back) start page
///
/// Native pages live in an overlay stack. Opening a web page from an
/// overlay records an anchor at the web history index that page gets;
/// Back at that index restores the overlay instead of leaving the site.
class NativeNavSession implements TabSession {
  NativeNavSession(this._web, {String? initialQuery}) {
    if (initialQuery != null) _pushSearch(initialQuery, notify: false);
    _web.state.addListener(_emit);
    _state.value = _compute();
  }

  final TabSession _web;
  final _state = ValueNotifier(const TabSessionState());

  /// Visible native pages, top last. Empty: the web page is visible.
  final List<_Native> _stack = [];

  /// Where Back from a web page returns to a native page.
  final List<_Anchor> _anchors = [];

  /// Native pages popped by Back, for Forward.
  final List<_Native> _overlayForward = [];

  /// The anchor Back last restored, for Forward to the web page again.
  _Redo? _redo;

  @override
  String get tabId => _web.tabId;

  @override
  bool get incognito => _web.incognito;

  @override
  ValueListenable<TabSessionState> get state => _state;

  TabSessionState get _w => _web.state.value;

  /// Prism Search query on screen, or null.
  String? get searchQuery => _stack.isEmpty ? null : _stack.last.query;

  void _emit() {
    final next = _compute();
    if (next != _state.value) _state.value = next;
  }

  TabSessionState _compute() {
    final w = _w;
    if (_stack.isEmpty) {
      return w.copyWith(
        canGoBack: w.canGoBack || _anchorAt(w.historyIndex) != null,
        canGoForward: w.canGoForward || _overlayForward.isNotEmpty,
      );
    }
    final top = _stack.last;
    final q = top.query;
    return TabSessionState(
      url: q == null ? null : PrismSearchUri.forQuery(q),
      title: q ?? '',
      canGoBack: !(_stack.length == 1 && _stack.first.isStart),
      canGoForward: _overlayForward.isNotEmpty || _redoValid,
      historyIndex: w.historyIndex,
    );
  }

  bool get _redoValid =>
      _redo != null && listEquals(_redo!.anchor.stack, _stack);

  _Anchor? _anchorAt(int index) {
    for (final a in _anchors.reversed) {
      if (a.webIndex == index) return a;
    }
    return null;
  }

  void _pushSearch(String query, {bool notify = true}) {
    final q = query.trim();
    if (q.isEmpty) return;
    if (_stack.isNotEmpty && _stack.last.query == q) return;
    // A search from the start page: Back returns to the start page.
    if (_stack.isEmpty && _w.isBlank) _stack.add(const _Native.start());
    _stack.add(_Native.search(q));
    _overlayForward.clear();
    _redo = null;
    if (notify) _emit();
  }

  @override
  Future<void> load(Uri url) async {
    final q = PrismSearchUri.queryOf(url);
    if (q != null) return _pushSearch(q);
    final index = _w.historyIndex + 1;
    // Loading truncates the web forward list: anchors past it are gone.
    _anchors.removeWhere((a) => a.webIndex >= index);
    if (_stack.isNotEmpty) {
      _anchors.add(_Anchor(List.of(_stack), index));
      _stack.clear();
    }
    _overlayForward.clear();
    _redo = null;
    _emit();
    await _web.load(url);
  }

  @override
  Future<void> goBack() async {
    if (_stack.isNotEmpty) {
      if (_stack.length == 1 && _stack.first.isStart) return;
      _overlayForward.add(_stack.removeLast());
      _emit();
      return;
    }
    final w = _w;
    final anchor = _anchorAt(w.historyIndex);
    if (anchor != null) {
      _anchors.remove(anchor);
      _stack.addAll(anchor.stack);
      _overlayForward.clear();
      // The page under the overlay goes back too, so leaving the overlay
      // shows what was there before. At index 0 there is nothing before
      // (the overlay then starts with the start page).
      final wentBack = w.canGoBack;
      _redo = _Redo(anchor, wentBack: wentBack);
      _emit();
      if (wentBack) await _web.goBack();
      return;
    }
    _overlayForward.clear();
    await _web.goBack();
  }

  @override
  Future<void> goForward() async {
    if (_overlayForward.isNotEmpty) {
      _stack.add(_overlayForward.removeLast());
      _emit();
      return;
    }
    if (_stack.isNotEmpty) {
      final redo = _redo;
      if (redo == null || !_redoValid) return;
      _stack.clear();
      _anchors.add(redo.anchor);
      _redo = null;
      _emit();
      if (redo.wentBack) await _web.goForward();
      return;
    }
    await _web.goForward();
  }

  @override
  Future<void> reload() async {
    if (_stack.isEmpty) await _web.reload();
  }

  @override
  Future<void> stopLoading() => _web.stopLoading();

  @override
  Future<Uint8List?> captureThumbnail() async =>
      _stack.isEmpty ? _web.captureThumbnail() : null;

  @override
  Widget buildView(BuildContext context, EdgeInsets insets) =>
      _web.buildView(context, insets);

  @override
  Future<void> dispose() async {
    _web.state.removeListener(_emit);
    _state.dispose();
    await _web.dispose();
  }
}

@immutable
class _Native {
  const _Native.start() : query = null;
  const _Native.search(String this.query);

  /// Null: the start page.
  final String? query;

  bool get isStart => query == null;

  @override
  bool operator ==(Object other) => other is _Native && other.query == query;

  @override
  int get hashCode => query.hashCode;
}

class _Anchor {
  _Anchor(this.stack, this.webIndex);

  final List<_Native> stack;

  /// Web history index of the first page opened from [stack].
  final int webIndex;
}

class _Redo {
  _Redo(this.anchor, {required this.wentBack});

  final _Anchor anchor;
  final bool wentBack;
}
