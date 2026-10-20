import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Web engine abstraction. The UI never talks to a WebView plugin directly:
/// it uses [BrowserEngine] / [TabSession]. Implementations: `AndroidEngine`
/// (Android System WebView), `WindowsEngine` (WebView2), `FakeEngine`
/// (tests, showcase, unsupported hosts).
///
/// Pragmatic exception to layer purity: [TabSession.buildView] returns a
/// Flutter widget, because a web view *is* a widget. Everything else here
/// is plain data and futures.
abstract interface class BrowserEngine {
  /// What this engine can really do on this platform. Settings screens use
  /// it to mark features as limited instead of faking them.
  EngineCapabilities get capabilities;

  /// Creates the per-tab session lazily (no native view until shown).
  TabSession createSession({
    required String tabId,
    required bool incognito,
    Uri? initialUrl,
    String? initialTitle,
  });

  /// Heavy one-time setup (WebView2 environment, profile dirs). Called on
  /// first use, never before the first frame. Idempotent.
  Future<void> warmUp();

  /// False after [warmUp] when the platform engine is missing (e.g. no
  /// WebView2 Runtime on Windows). The UI then explains how to fix it.
  bool get isAvailable;
}

@immutable
class EngineCapabilities {
  const EngineCapabilities({
    required this.name,
    required this.contentUnderChromeBlurs,
    required this.requestInterception,
    required this.perTabCookieIsolation,
    required this.dnsOverHttps,
    required this.desktopMode,
    required this.findInPage,
    required this.printToPdf,
    required this.incognitoWithoutDisk,
  });

  /// Human-readable engine name for "About" / diagnostics.
  final String name;

  /// True when Flutter can blur the page under glass chrome (the page is
  /// composited as a Flutter texture). False => glass degrades to a denser
  /// tint over web content (no blur artifacts).
  final bool contentUnderChromeBlurs;

  /// Network-level blocking of subresource requests (ad/tracker blocker).
  final bool requestInterception;
  final bool perTabCookieIsolation;
  final bool dnsOverHttps;
  final bool desktopMode;
  final bool findInPage;
  final bool printToPdf;

  /// Incognito keeps nothing on disk (vs. a temp profile that is wiped).
  final bool incognitoWithoutDisk;
}

enum PageSecurityLevel { secure, insecure, internal }

/// Snapshot of one tab's engine state.
@immutable
class TabSessionState {
  const TabSessionState({
    this.url,
    this.title = '',
    this.progress = 1,
    this.canGoBack = false,
    this.canGoForward = false,
    this.error,
    this.blockedCount = 0,
  });

  /// Requests blocked on the current page (blocker, stage 5).
  final int blockedCount;

  /// Null until the first navigation (tab shows the native start page).
  final Uri? url;
  final String title;

  /// 0..1; 1 when idle.
  final double progress;
  final bool canGoBack;
  final bool canGoForward;

  /// Localized-agnostic error description from the engine, if the last
  /// navigation failed.
  final String? error;

  bool get loading => progress < 1;
  bool get isBlank => url == null;

  PageSecurityLevel get security => switch (url?.scheme) {
    null || 'about' || 'prism' => PageSecurityLevel.internal,
    'https' => PageSecurityLevel.secure,
    _ => PageSecurityLevel.insecure,
  };

  TabSessionState copyWith({
    Uri? url,
    String? title,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    String? error,
    bool clearError = false,
    int? blockedCount,
  }) => TabSessionState(
    url: url ?? this.url,
    title: title ?? this.title,
    progress: progress ?? this.progress,
    canGoBack: canGoBack ?? this.canGoBack,
    canGoForward: canGoForward ?? this.canGoForward,
    error: clearError ? null : (error ?? this.error),
    blockedCount: blockedCount ?? this.blockedCount,
  );

  @override
  bool operator ==(Object other) =>
      other is TabSessionState &&
      other.url == url &&
      other.title == title &&
      other.progress == progress &&
      other.canGoBack == canGoBack &&
      other.canGoForward == canGoForward &&
      other.error == error &&
      other.blockedCount == blockedCount;

  @override
  int get hashCode => Object.hash(
    url,
    title,
    progress,
    canGoBack,
    canGoForward,
    error,
    blockedCount,
  );
}

/// One tab's live page.
abstract interface class TabSession {
  String get tabId;
  bool get incognito;

  ValueListenable<TabSessionState> get state;

  Future<void> load(Uri url);
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
  Future<void> stopLoading();

  /// PNG preview for the tab switcher (null if unavailable).
  Future<Uint8List?> captureThumbnail();

  /// The page widget. Created on first build, so an unseen tab costs no
  /// native view (lazy tabs). [insets] is the chrome overlapping the page:
  /// engines that cannot pad their content are laid out inside it instead.
  Widget buildView(BuildContext context, EdgeInsets insets);

  Future<void> dispose();
}
