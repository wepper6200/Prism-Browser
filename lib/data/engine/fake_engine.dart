import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/engine/browser_engine.dart';
import 'fake_page.dart';

/// Deterministic in-memory engine for tests, showcase boards and hosts
/// without a supported web engine. Navigation completes synchronously.
class FakeEngine implements BrowserEngine {
  FakeEngine({
    this.progress = 1,
    this.blockedPerPage = 12,
    this.blursContent = true,
  });

  /// False simulates Hybrid Composition (glass must degrade).
  final bool blursContent;

  /// Progress every loaded page reports (showcase can show a loading bar).
  final double progress;
  final int blockedPerPage;

  final List<String> loadLog = [];

  @override
  EngineCapabilities get capabilities => EngineCapabilities(
    name: 'Fake',
    contentUnderChromeBlurs: blursContent,
    requestInterception: true,
    perTabCookieIsolation: true,
    dnsOverHttps: false,
    desktopMode: true,
    findInPage: true,
    printToPdf: false,
    incognitoWithoutDisk: true,
  );

  @override
  Future<void> warmUp() async {}

  @override
  bool get isAvailable => true;

  final _downloads = StreamController<DownloadRequest>.broadcast();

  @override
  Stream<DownloadRequest> get downloadRequests => _downloads.stream;

  /// Tests: a page asks to download a file.
  void simulateDownload(DownloadRequest request) => _downloads.add(request);

  @override
  Future<String?> cookieHeader(Uri url, {required bool incognito}) async =>
      null;

  @override
  TabSession createSession({
    required String tabId,
    required bool incognito,
    Uri? initialUrl,
    String? initialTitle,
  }) => _FakeSession(this, tabId, incognito, initialUrl, initialTitle);
}

class _FakeSession implements TabSession {
  _FakeSession(
    this._engine,
    this.tabId,
    this.incognito,
    Uri? url,
    String? title,
  ) : _state = ValueNotifier(
        TabSessionState(
          url: url,
          title: title ?? url?.host ?? '',
          progress: url == null ? 1 : _engine.progress,
          canGoBack: url != null,
          blockedCount: url == null ? 0 : _engine.blockedPerPage,
        ),
      );

  final FakeEngine _engine;
  final ValueNotifier<TabSessionState> _state;
  final List<Uri> _back = [];
  final List<Uri> _forward = [];

  @override
  final String tabId;
  @override
  final bool incognito;

  @override
  ValueListenable<TabSessionState> get state => _state;

  @override
  Future<void> load(Uri url) async {
    _engine.loadLog.add(url.toString());
    final current = _state.value.url;
    if (current != null) _back.add(current);
    _forward.clear();
    _go(url);
  }

  void _go(Uri url) {
    _state.value = TabSessionState(
      url: url,
      title: url.host,
      progress: _engine.progress,
      canGoBack: _back.isNotEmpty,
      canGoForward: _forward.isNotEmpty,
      blockedCount: _engine.blockedPerPage,
    );
  }

  @override
  Future<void> goBack() async {
    if (_back.isEmpty) return;
    _forward.add(_state.value.url!);
    _go(_back.removeLast());
  }

  @override
  Future<void> goForward() async {
    if (_forward.isEmpty) return;
    _back.add(_state.value.url!);
    _go(_forward.removeLast());
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> stopLoading() async =>
      _state.value = _state.value.copyWith(progress: 1);

  @override
  Future<Uint8List?> captureThumbnail() async => null;

  @override
  Widget buildView(BuildContext context, EdgeInsets insets) =>
      MockWebPage(topInset: insets.top, bottomInset: insets.bottom);

  @override
  Future<void> dispose() async => _state.dispose();
}
