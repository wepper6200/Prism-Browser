import 'package:flutter/foundation.dart';

import '../engine/punycode.dart';

/// Browser domain models. Pure Dart: persisted by drift in stage 4,
/// served from in-memory mocks in stage 2.

@immutable
class TabGroup {
  const TabGroup({required this.id, required this.name, required this.color});

  final String id;
  final String name;

  /// ARGB, user-chosen group color.
  final int color;
}

@immutable
class BrowserTab {
  const BrowserTab({
    required this.id,
    required this.title,
    required this.url,
    this.pinned = false,
    this.incognito = false,
    this.groupId,
    this.loaded = true,
  });

  final String id;
  final String title;

  /// Empty url = new tab (start page).
  final String url;
  final bool pinned;
  final bool incognito;
  final String? groupId;

  /// False when the tab was unloaded to free memory (lazy restore).
  final bool loaded;

  bool get isStartPage => url.isEmpty;

  String get host {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    final h = uri?.host ?? url;
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  BrowserTab copyWith({
    String? title,
    String? url,
    bool? pinned,
    String? groupId,
    bool clearGroup = false,
    bool? loaded,
  }) => BrowserTab(
    id: id,
    title: title ?? this.title,
    url: url ?? this.url,
    pinned: pinned ?? this.pinned,
    incognito: incognito,
    groupId: clearGroup ? null : (groupId ?? this.groupId),
    loaded: loaded ?? this.loaded,
  );
}

@immutable
class BookmarkFolder {
  const BookmarkFolder({required this.id, required this.name, this.parentId});

  final String id;
  final String name;
  final String? parentId;
}

@immutable
class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.folderId,
  });

  final String id;
  final String title;
  final String url;
  final String? folderId;
}

@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.visitedAt,
  });

  final String id;
  final String title;
  final String url;
  final DateTime visitedAt;
}

enum DownloadState { running, paused, completed, failed }

@immutable
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.fileName,
    required this.url,
    required this.totalBytes,
    required this.receivedBytes,
    required this.state,
    this.filePath = '',
    this.contentUri,
    this.mimeType,
    this.createdAt,
    this.incognito = false,
  });

  final String id;
  final String fileName;
  final String url;

  /// -1 when the server did not say.
  final int totalBytes;
  final int receivedBytes;
  final DownloadState state;

  /// Where the file is written.
  final String filePath;

  /// Android: content:// URI of the file in the public Downloads folder.
  final String? contentUri;
  final String? mimeType;
  final DateTime? createdAt;

  /// Started from an incognito tab: listed only until the app closes.
  final bool incognito;

  bool get sizeKnown => totalBytes > 0;
  double? get progress =>
      sizeKnown ? (receivedBytes / totalBytes).clamp(0.0, 1.0) : null;

  DownloadItem copyWith({
    DownloadState? state,
    int? totalBytes,
    int? receivedBytes,
    String? filePath,
    String? fileName,
    String? contentUri,
  }) => DownloadItem(
    id: id,
    fileName: fileName ?? this.fileName,
    url: url,
    totalBytes: totalBytes ?? this.totalBytes,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    state: state ?? this.state,
    filePath: filePath ?? this.filePath,
    contentUri: contentUri ?? this.contentUri,
    mimeType: mimeType,
    createdAt: createdAt,
    incognito: incognito,
  );
}

enum SearchEngineId {
  duckduckgo,
  brave,
  startpage,
  google,
  bing,
  yandex,
  custom,
}

@immutable
class SearchEngine {
  const SearchEngine({
    required this.id,
    required this.name,
    required this.queryTemplate,
    required this.privacyFriendly,
  });

  final SearchEngineId id;
  final String name;

  /// `%s` is replaced by the URL-encoded query.
  final String queryTemplate;

  /// Shown as a "private" badge in onboarding/settings.
  final bool privacyFriendly;

  static const all = [
    SearchEngine(
      id: SearchEngineId.duckduckgo,
      name: 'DuckDuckGo',
      queryTemplate: 'https://duckduckgo.com/?q=%s',
      privacyFriendly: true,
    ),
    SearchEngine(
      id: SearchEngineId.brave,
      name: 'Brave Search',
      queryTemplate: 'https://search.brave.com/search?q=%s',
      privacyFriendly: true,
    ),
    SearchEngine(
      id: SearchEngineId.startpage,
      name: 'Startpage',
      queryTemplate: 'https://www.startpage.com/do/search?q=%s',
      privacyFriendly: true,
    ),
    SearchEngine(
      id: SearchEngineId.google,
      name: 'Google',
      queryTemplate: 'https://www.google.com/search?q=%s',
      privacyFriendly: false,
    ),
    SearchEngine(
      id: SearchEngineId.bing,
      name: 'Bing',
      queryTemplate: 'https://www.bing.com/search?q=%s',
      privacyFriendly: false,
    ),
    SearchEngine(
      id: SearchEngineId.yandex,
      name: 'Yandex',
      queryTemplate: 'https://yandex.ru/search/?text=%s',
      privacyFriendly: false,
    ),
  ];

  static SearchEngine byId(SearchEngineId id) =>
      all.firstWhere((e) => e.id == id, orElse: () => all.first);

  /// User-defined engine ("Custom URL"). Privacy unknown, so no badge.
  factory SearchEngine.custom({
    required String name,
    required String template,
  }) => SearchEngine(
    id: SearchEngineId.custom,
    name: name,
    queryTemplate: template,
    privacyFriendly: false,
  );
}

enum CustomTemplateError {
  empty,
  invalidUrl,
  missingPlaceholder,
  tooManyPlaceholders,
}

/// Validation result: a normalized template or an error.
@immutable
class CustomTemplateResult {
  const CustomTemplateResult._(this.template, this.error);

  final String? template;
  final CustomTemplateError? error;

  bool get isValid => error == null;

  /// Plain HTTP leaks every query to the network: the UI warns.
  bool get insecure => template?.startsWith('http://') ?? false;
}

/// Checks and normalizes a custom search URL template.
abstract final class CustomSearchTemplate {
  static const placeholder = '%s';

  static CustomTemplateResult validate(String input) {
    var t = input.trim();
    if (t.isEmpty) {
      return const CustomTemplateResult._(null, CustomTemplateError.empty);
    }
    // OpenSearch descriptions use {searchTerms}.
    t = t.replaceAll('{searchTerms}', placeholder);
    final count = placeholder.allMatches(t).length;
    if (count == 0) {
      return const CustomTemplateResult._(
        null,
        CustomTemplateError.missingPlaceholder,
      );
    }
    if (count > 1) {
      return const CustomTemplateResult._(
        null,
        CustomTemplateError.tooManyPlaceholders,
      );
    }
    final hasScheme = RegExp(
      r'^[a-z][a-z0-9+.-]*://',
      caseSensitive: false,
    ).hasMatch(t);
    if (!hasScheme) {
      if (RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(t) &&
          !RegExp(r'^[^/:]+:\d').hasMatch(t)) {
        // javascript:, data:, mailto: ... never.
        return const CustomTemplateResult._(
          null,
          CustomTemplateError.invalidUrl,
        );
      }
      t = 'https://$t';
    }
    // Validate with a sample query in place of the placeholder.
    final probe = Uri.tryParse(t.replaceFirst(placeholder, 'prism'));
    if (probe == null ||
        !(probe.scheme == 'https' || probe.scheme == 'http') ||
        probe.host.isEmpty ||
        !probe.host.contains(RegExp(r'[.\]]|^localhost$'))) {
      return const CustomTemplateResult._(null, CustomTemplateError.invalidUrl);
    }
    // Host to ASCII (IDN), scheme lower-case; the rest is kept verbatim.
    final m = RegExp(
      r'^([a-z]+)://([^/?#:]+)(.*)$',
      caseSensitive: false,
    ).firstMatch(t)!;
    final normalized = '${m[1]!.toLowerCase()}://${_asciiHost(m[2]!)}${m[3]}';
    return CustomTemplateResult._(normalized, null);
  }

  /// Display name proposal from the template host ("search.example.org").
  static String suggestName(String template) {
    final host =
        Uri.tryParse(template.replaceFirst(placeholder, 'q'))?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  static String _asciiHost(String host) => host.runes.any((c) => c >= 0x80)
      ? Punycode.toAscii(host)
      : host.toLowerCase();
}

enum PrivacyProfile { standard, strict, custom }

/// Toggles behind the privacy profiles. Stage 2: UI state only; stage 5
/// wires them to the blocker / engine and persists them.
@immutable
class PrivacySettings {
  const PrivacySettings({
    this.profile = PrivacyProfile.standard,
    this.blockTrackers = true,
    this.blockAds = true,
    this.httpsOnly = true,
    this.blockThirdPartyCookies = true,
    this.clearOnExit = false,
    this.stripTrackingParams = true,
    this.globalPrivacyControl = true,
    this.antiFingerprinting = false,
    this.blockWebRtcLeak = true,
    this.dnsOverHttps = false,
    this.appLock = false,
  });

  factory PrivacySettings.forProfile(PrivacyProfile p) => switch (p) {
    PrivacyProfile.standard => const PrivacySettings(),
    PrivacyProfile.strict => const PrivacySettings(
      profile: PrivacyProfile.strict,
      clearOnExit: true,
      antiFingerprinting: true,
      dnsOverHttps: true,
    ),
    PrivacyProfile.custom => const PrivacySettings(
      profile: PrivacyProfile.custom,
    ),
  };

  final PrivacyProfile profile;
  final bool blockTrackers;
  final bool blockAds;
  final bool httpsOnly;
  final bool blockThirdPartyCookies;
  final bool clearOnExit;
  final bool stripTrackingParams;
  final bool globalPrivacyControl;
  final bool antiFingerprinting;
  final bool blockWebRtcLeak;
  final bool dnsOverHttps;
  final bool appLock;

  PrivacySettings copyWith({
    PrivacyProfile? profile,
    bool? blockTrackers,
    bool? blockAds,
    bool? httpsOnly,
    bool? blockThirdPartyCookies,
    bool? clearOnExit,
    bool? stripTrackingParams,
    bool? globalPrivacyControl,
    bool? antiFingerprinting,
    bool? blockWebRtcLeak,
    bool? dnsOverHttps,
    bool? appLock,
  }) => PrivacySettings(
    profile: profile ?? this.profile,
    blockTrackers: blockTrackers ?? this.blockTrackers,
    blockAds: blockAds ?? this.blockAds,
    httpsOnly: httpsOnly ?? this.httpsOnly,
    blockThirdPartyCookies:
        blockThirdPartyCookies ?? this.blockThirdPartyCookies,
    clearOnExit: clearOnExit ?? this.clearOnExit,
    stripTrackingParams: stripTrackingParams ?? this.stripTrackingParams,
    globalPrivacyControl: globalPrivacyControl ?? this.globalPrivacyControl,
    antiFingerprinting: antiFingerprinting ?? this.antiFingerprinting,
    blockWebRtcLeak: blockWebRtcLeak ?? this.blockWebRtcLeak,
    dnsOverHttps: dnsOverHttps ?? this.dnsOverHttps,
    appLock: appLock ?? this.appLock,
  );
}

enum SitePermissionKind { camera, microphone, location, notifications, popups }

enum PermissionDecision { ask, allow, block }

@immutable
class SitePermission {
  const SitePermission({
    required this.host,
    required this.kind,
    required this.decision,
  });

  final String host;
  final SitePermissionKind kind;
  final PermissionDecision decision;
}
