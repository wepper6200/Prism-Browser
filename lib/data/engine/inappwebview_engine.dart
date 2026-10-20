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
    // WebView2 InPrivate exists; plugin support verified in stage 4.
    incognitoWithoutDisk: false,
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
         TabSessionState(url: initialUrl, title: initialTitle ?? ''),
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

  void _set(TabSessionState s) {
    if (s != _state.value) _state.value = s;
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
