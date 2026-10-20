import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/engine/browser_engine.dart';

/// Shared implementation over flutter_inappwebview (Android System WebView,
/// Windows WebView2). Platform differences live in [AndroidEngine] /
/// [WindowsEngine]: settings, capabilities and environment setup.
abstract class InAppWebViewEngine implements BrowserEngine {
  /// Privacy-first defaults shared by every platform.
  InAppWebViewSettings settings({required bool incognito}) =>
      InAppWebViewSettings(
        incognito: incognito,
        // Downloads are handed to Prism (onDownloadStarting).
        useOnDownloadStart: true,
        // Third-party cookies off by default (privacy profile, stage 5).
        thirdPartyCookiesEnabled: false,
        // Safe Browsing sends lookups to Google: off (no third-party calls
        // without consent). Opt-in toggle planned with stage 5.
        safeBrowsingEnabled: false,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        isInspectable: kDebugMode,
        mediaPlaybackRequiresUserGesture: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        allowFileAccess: false,
        allowContentAccess: false,
        // Permission prompts are routed through Prism (stage 5).
        geolocationEnabled: false,
        supportMultipleWindows: false,
        javaScriptCanOpenWindowsAutomatically: false,
        disableDefaultErrorPage: false,
      );

  WebViewEnvironment? get environment => null;

  final _downloads = StreamController<DownloadRequest>.broadcast();

  @override
  Stream<DownloadRequest> get downloadRequests => _downloads.stream;

  @override
  Future<String?> cookieHeader(Uri url, {required bool incognito}) async {
    if (incognito) return null;
    try {
      final cookies = await CookieManager.instance(
        webViewEnvironment: environment,
      ).getCookies(url: WebUri.uri(url));
      if (cookies.isEmpty) return null;
      return cookies.map((c) => '${c.name}=${c.value}').join('; ');
    } on Object {
      return null;
    }
  }

  @override
  TabSession createSession({
    required String tabId,
    required bool incognito,
    Uri? initialUrl,
    String? initialTitle,
  }) => InAppTabSession(
    engine: this,
    tabId: tabId,
    incognito: incognito,
    initialUrl: initialUrl,
    initialTitle: initialTitle,
  );
}

/// Android System WebView.
class AndroidEngine extends InAppWebViewEngine {
  AndroidEngine({this.hybridComposition = false});

  /// Spike result (stage 3): Texture Layer Hybrid Composition (false) lets
  /// Flutter blur the page under glass chrome; Hybrid Composition (true) is
  /// composited by Android, so Flutter cannot sample it. See DECISIONES.md.
  final bool hybridComposition;

  @override
  EngineCapabilities get capabilities => EngineCapabilities(
    name: 'Android System WebView',
    contentUnderChromeBlurs: !hybridComposition,
    // shouldInterceptRequest can cancel subresources.
    requestInterception: true,
    // One CookieManager per app process in WebView (no Profile API in the
    // plugin): tabs share cookies, incognito is not disk-free.
    perTabCookieIsolation: false,
    dnsOverHttps: false,
    desktopMode: true,
    findInPage: true,
    printToPdf: true,
    incognitoWithoutDisk: false,
  );

  @override
  Future<void> warmUp() async {}

  @override
  bool get isAvailable => true;

  @override
  InAppWebViewSettings settings({required bool incognito}) =>
      super.settings(incognito: incognito)
        // NOT the plugin's incognito flag on Android: it calls
        // CookieManager.removeAllCookies(), which would sign the user out
        // of every regular tab. WebView has one cookie jar per app (no
        // Profile API in the plugin), so incognito here means: no cache,
        // no history/session/downloads list on disk. See DECISIONES.md.
        ..incognito = false
        ..cacheMode = incognito
            ? CacheMode.LOAD_NO_CACHE
            : CacheMode.LOAD_DEFAULT
        ..useHybridComposition = hybridComposition
        ..algorithmicDarkeningAllowed = false;
}

/// Microsoft Edge WebView2 (Windows). Rendered into a Flutter texture, so
/// glass chrome can blur page content.
class WindowsEngine extends InAppWebViewEngine {
  WebViewEnvironment? _env;
  Future<void>? _warming;

  /// WebView2 Runtime version, or null when it is not installed.
  String? runtimeVersion;

  @override
  WebViewEnvironment? get environment => _env;

  @override
  EngineCapabilities get capabilities => const EngineCapabilities(
    name: 'Microsoft Edge WebView2',
    contentUnderChromeBlurs: true,
    // To verify in stage 5 (WebResourceRequested via the plugin).
    requestInterception: false,
    perTabCookieIsolation: false,
    // Possible via browser arguments; verified and enabled in stage 5.
    dnsOverHttps: false,
    desktopMode: true,
    findInPage: true,
    printToPdf: true,
    // Controller option IsInPrivateModeEnabled (plugin: settings.incognito):
    // separate in-memory profile, nothing written to disk.
    incognitoWithoutDisk: true,
  );

  @override
  Future<void> warmUp() => _warming ??= _init();

  @override
  bool get isAvailable => runtimeVersion != null;

  Future<void> _init() async {
    runtimeVersion = await WebViewEnvironment.getAvailableVersion();
    if (runtimeVersion == null) return;
    // LocalAppData\Prism\Prism Browser: cookies/cache must not roam with
    // the user profile (Roaming), and stay on this machine only.
    final dir = await getApplicationCacheDirectory();
    _env = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(
        userDataFolder: '${dir.path}${Platform.pathSeparator}webview2',
      ),
    );
  }
}

class InAppTabSession implements TabSession {
  InAppTabSession({
    required this.engine,
    required this.tabId,
    required this.incognito,
    Uri? initialUrl,
    String? initialTitle,
  }) : _pending = initialUrl,
       _state = ValueNotifier(
         // A restored tab is pending its load: not "finished" (history
         // records visits only when a load completes).
         TabSessionState(
           url: initialUrl,
           title: initialTitle ?? '',
           progress: initialUrl == null ? 1 : 0.05,
         ),
       );

  final InAppWebViewEngine engine;
  @override
  final String tabId;
  @override
  final bool incognito;

  final ValueNotifier<TabSessionState> _state;

  /// Keeps the native WebView alive while the widget is off-screen (tab
  /// switching does not reload the page).
  final _keepAlive = InAppWebViewKeepAlive();
  InAppWebViewController? _c;
  Uri? _pending;

  @override
  ValueListenable<TabSessionState> get state => _state;

  /// URLs that turned out to be downloads: never shown as the page URL
  /// (WebView may still report them), so they are not saved in the session
  /// and do not download again when the tab is restored.
  final _downloadUrls = <String>{};

  /// The last two pages that finished loading (to step back from a
  /// download URL that was reported as loaded before it became a download).
  Uri? _committed;
  Uri? _committedBefore;

  void _set(TabSessionState s) {
    final url = s.url;
    if (url != null && _downloadUrls.contains(url.toString())) {
      final back = _committed;
      s = back == null
          ? const TabSessionState()
          : s.copyWith(url: back, progress: 1, clearError: true);
    } else if (url != null &&
        !s.loading &&
        s.error == null &&
        url != _committed) {
      _committedBefore = _committed;
      _committed = url;
    }
    if (s != _state.value) _state.value = s;
  }

  void _markDownload(Uri url) {
    _downloadUrls.add(url.toString());
    if (_committed == url) {
      _committed = _committedBefore;
      _committedBefore = null;
    }
    _set(_state.value.copyWith(progress: 1));
  }

  Future<void> _syncHistory() async {
    final c = _c;
    if (c == null) return;
    final back = await c.canGoBack();
    final fwd = await c.canGoForward();
    _set(_state.value.copyWith(canGoBack: back, canGoForward: fwd));
  }

  @override
  Future<void> load(Uri url) async {
    _set(_state.value.copyWith(url: url, progress: 0.05, clearError: true));
    final c = _c;
    if (c == null) {
      _pending = url;
      return;
    }
    await c.loadUrl(urlRequest: URLRequest(url: WebUri.uri(url)));
  }

  @override
  Future<void> goBack() async => _c?.goBack();

  @override
  Future<void> goForward() async => _c?.goForward();

  @override
  Future<void> reload() async => _c?.reload();

  @override
  Future<void> stopLoading() async {
    await _c?.stopLoading();
    _set(_state.value.copyWith(progress: 1));
  }

  @override
  Future<Uint8List?> captureThumbnail() async => _c?.takeScreenshot(
    screenshotConfiguration: ScreenshotConfiguration(
      compressFormat: CompressFormat.JPEG,
      quality: 70,
    ),
  );

  @override
  Widget buildView(BuildContext context, EdgeInsets insets) {
    final pending = _pending;
    final view = InAppWebView(
      keepAlive: _keepAlive,
      webViewEnvironment: engine.environment,
      initialSettings: engine.settings(incognito: incognito),
      initialUrlRequest: pending == null
          ? null
          : URLRequest(url: WebUri.uri(pending)),
      onWebViewCreated: (c) {
        _c = c;
        _pending = null;
      },
      onLoadStart: (c, url) => _set(
        _state.value.copyWith(
          url: url?.uriValue,
          progress: 0.05,
          clearError: true,
        ),
      ),
      onProgressChanged: (c, p) => _set(
        _state.value.copyWith(
          progress: p >= 100 ? 1 : (p / 100).clamp(0.05, 0.99),
        ),
      ),
      onTitleChanged: (c, title) =>
          _set(_state.value.copyWith(title: title ?? '')),
      onUpdateVisitedHistory: (c, url, _) {
        _set(_state.value.copyWith(url: url?.uriValue));
        unawaited(_syncHistory());
      },
      onLoadStop: (c, url) async {
        _set(_state.value.copyWith(url: url?.uriValue, progress: 1));
        await _syncHistory();
      },
      onDownloadStarting: (c, request) {
        // The navigation became a download: the page did not change, so
        // show its URL again (or the start page) and stop the progress bar.
        _markDownload(request.url);
        unawaited(_syncHistory());
        engine._downloads.add(
          DownloadRequest(
            url: request.url,
            incognito: incognito,
            contentDisposition: request.contentDisposition,
            mimeType: request.mimeType,
            contentLength: request.contentLength,
            // Windows: the plugin fills this from Content-Disposition.
            suggestedFileName: request.suggestedFilename,
            userAgent: request.userAgent,
          ),
        );
        // Windows: stop WebView2's own download (Prism downloads it).
        return DownloadStartResponse(
          handled: true,
          action: DownloadStartResponseAction.CANCEL,
        );
      },
      onReceivedError: (c, request, error) {
        if (request.isForMainFrame ?? true) {
          _set(_state.value.copyWith(progress: 1, error: error.description));
        }
      },
    );
    // The page cannot be padded natively, so it is laid out inside the
    // chrome insets that must stay readable (top bar); bottom chrome floats
    // over the page (and blurs it where the engine allows).
    return Padding(
      padding: EdgeInsets.only(top: insets.top),
      child: view,
    );
  }

  @override
  Future<void> dispose() async {
    _c = null;
    await InAppWebViewController.disposeKeepAlive(_keepAlive);
    _state.dispose();
  }
}
