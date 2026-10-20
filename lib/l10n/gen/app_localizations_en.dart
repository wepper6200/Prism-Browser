// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prism Browser';

  @override
  String get styleGlass => 'Liquid Glass';

  @override
  String get styleMaterial => 'Material 3';

  @override
  String get styleGlassDesc => 'Clear glass, highlights and floating bars';

  @override
  String get styleMaterialDesc =>
      'Tonal colors, living shapes and expressive motion';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get designGalleryTitle => 'Design system';

  @override
  String get sectionStyle => 'Interface style';

  @override
  String get sectionTheme => 'Theme';

  @override
  String get sectionButtons => 'Buttons';

  @override
  String get sectionIconButtons => 'Icon buttons';

  @override
  String get sectionSurfaces => 'Surfaces';

  @override
  String get sectionTabs => 'Tab cards';

  @override
  String get sectionTypography => 'Typography';

  @override
  String get sectionControls => 'Controls';

  @override
  String get buttonPrimary => 'Open';

  @override
  String get buttonSecondary => 'Cancel';

  @override
  String get buttonGhost => 'More';

  @override
  String get actionBack => 'Back';

  @override
  String get actionForward => 'Forward';

  @override
  String get actionReload => 'Reload';

  @override
  String get actionStop => 'Stop loading';

  @override
  String get actionTabs => 'Tabs';

  @override
  String get actionMenu => 'Menu';

  @override
  String get actionCloseTab => 'Close tab';

  @override
  String get actionNewTab => 'New tab';

  @override
  String get actionShowSheet => 'Show sheet';

  @override
  String get actionHome => 'Home';

  @override
  String get actionBookmark => 'Bookmark';

  @override
  String get actionSettings => 'Settings';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionPrevious => 'Previous match';

  @override
  String get actionNext => 'Next match';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionOpenFile => 'Open file';

  @override
  String get actionClearQuery => 'Clear';

  @override
  String get omniboxHint => 'Search or enter address';

  @override
  String omniboxSearchWith(String engine) {
    return 'Search with $engine';
  }

  @override
  String get omniboxFill => 'Fill in address bar';

  @override
  String get omniboxGoTo => 'Go to address';

  @override
  String get emptyBookmarksTitle => 'No bookmarks yet';

  @override
  String get emptyBookmarksBody => 'Tap the star on any page to keep it here.';

  @override
  String get emptyHistoryTitle => 'History is empty';

  @override
  String get emptyHistoryBody =>
      'Pages you visit in normal tabs appear here. Incognito tabs leave nothing.';

  @override
  String get emptyDownloadsTitle => 'No downloads';

  @override
  String get emptyDownloadsBody => 'Files you download will appear here.';

  @override
  String get suggestionSearch => 'Search';

  @override
  String get suggestionHistory => 'History';

  @override
  String get suggestionBookmark => 'Bookmark';

  @override
  String get secureConnection => 'Secure connection';

  @override
  String get insecureConnection => 'Not secure';

  @override
  String tabsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs open',
      one: '1 tab open',
    );
    return '$_temp0';
  }

  @override
  String shieldButton(int count) {
    return 'Protection: $count blocked';
  }

  @override
  String get sheetTitle => 'Page actions';

  @override
  String get sheetBody =>
      'Sheets, menus and dialogs share one surface abstraction across styles.';

  @override
  String trackersBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trackers blocked',
      one: '1 tracker blocked',
      zero: 'No trackers blocked',
    );
    return '$_temp0';
  }

  @override
  String get typeDisplay => 'Fast. Private. Yours.';

  @override
  String get typeTitle => 'Title text';

  @override
  String get typeBody =>
      'Body text keeps 1.5 line height for comfortable reading on any surface.';

  @override
  String get typeLabel => 'LABEL';

  @override
  String get glassIntensity => 'Glass intensity';

  @override
  String get glassAuto => 'Auto';

  @override
  String get glassManual => 'Manual';

  @override
  String get glassOff => 'Off';

  @override
  String get glassAutoHint =>
      'Effects are reduced in battery saver, on low-end devices and when the system asks for less transparency.';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionSub => 'The system setting is always respected too';

  @override
  String get pinnedTab => 'Pinned';

  @override
  String get startTopSites => 'Top sites';

  @override
  String get startProtection => 'Protection this week';

  @override
  String get statTrackers => 'Trackers';

  @override
  String get statAds => 'Ads';

  @override
  String get statTime => 'Time saved';

  @override
  String statTimeValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get incognitoTitle => 'Incognito mode';

  @override
  String get incognitoBody =>
      'Prism won\'t keep history, cookies or form data from these tabs, and nothing is written to disk. Downloads and bookmarks you save stay. Websites and your network can still see your traffic.';

  @override
  String get tabsTitle => 'Tabs';

  @override
  String get tabsNormal => 'Tabs';

  @override
  String get tabsIncognito => 'Incognito';

  @override
  String get tabsAllGroups => 'All';

  @override
  String get tabsUnloaded => 'Unloaded to save memory';

  @override
  String get tabsCloseAll => 'Close all';

  @override
  String get tabsEmptyIncognito => 'No incognito tabs';

  @override
  String get tabsEmptyIncognitoBody =>
      'Incognito tabs keep nothing after you close them.';

  @override
  String get menuNewIncognito => 'New incognito tab';

  @override
  String get menuBookmarks => 'Bookmarks';

  @override
  String get menuHistory => 'History';

  @override
  String get menuDownloads => 'Downloads';

  @override
  String get menuFindInPage => 'Find in page';

  @override
  String get menuReader => 'Reader mode';

  @override
  String get menuDesktopSite => 'Desktop site';

  @override
  String get menuShare => 'Share';

  @override
  String get menuSavePdf => 'Save as PDF';

  @override
  String get menuZoom => 'Zoom';

  @override
  String get menuZoomOut => 'Zoom out';

  @override
  String get menuZoomIn => 'Zoom in';

  @override
  String get menuForgetAll => 'Forget everything';

  @override
  String get menuDuplicate => 'Duplicate tab';

  @override
  String get menuPin => 'Pin tab';

  @override
  String findCount(int current, int total) {
    return '$current of $total';
  }

  @override
  String shieldTitle(String host) {
    return 'Protection on $host';
  }

  @override
  String get shieldOn => 'Trackers and ads are blocked';

  @override
  String get shieldOnSub => 'Turn off only if the site is broken';

  @override
  String get statCookies => 'Cookies';

  @override
  String get shieldBlockedList => 'Blocked requests';

  @override
  String get kindTracker => 'Tracker';

  @override
  String get kindAd => 'Ad';

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get bookmarksSearch => 'Search bookmarks';

  @override
  String get bookmarksFolders => 'Folders';

  @override
  String get bookmarksUnsorted => 'Other bookmarks';

  @override
  String bookmarksInFolder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get historySearch => 'Search history';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyEarlier => 'Earlier';

  @override
  String get historyClear => 'Clear history';

  @override
  String get clearRangeHour => 'Last hour';

  @override
  String get clearRangeDay => 'Last 24 hours';

  @override
  String get clearRangeWeek => 'Last 7 days';

  @override
  String get clearRangeAll => 'All time';

  @override
  String get clearHistoryBody =>
      'History, cookies and cache for the selected period will be deleted. This can\'t be undone.';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadPaused => 'Paused';

  @override
  String get downloadFailed => 'Failed — network error';

  @override
  String get downloadDone => 'Completed';

  @override
  String downloadProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String unitKB(String v) {
    return '$v KB';
  }

  @override
  String unitMB(String v) {
    return '$v MB';
  }

  @override
  String unitGB(String v) {
    return '$v GB';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSub => 'Style, theme, color, address bar';

  @override
  String get settingsPrivacy => 'Privacy & security';

  @override
  String get settingsPrivacySub => 'Trackers, cookies, HTTPS, app lock';

  @override
  String get settingsSearch => 'Search engine';

  @override
  String get settingsPermissions => 'Site permissions';

  @override
  String get settingsPermissionsSub =>
      'Camera, microphone, location, notifications';

  @override
  String get settingsDefaultBrowser => 'Default browser';

  @override
  String get settingsDefaultBrowserSub => 'Open links from other apps in Prism';

  @override
  String get settingsAbout => 'About Prism';

  @override
  String settingsAboutSub(String version) {
    return 'Version $version · no telemetry';
  }

  @override
  String get settingsDesign => 'Design system';

  @override
  String get settingsGeneral => 'General';

  @override
  String get appearanceStyle => 'Interface style';

  @override
  String get appearanceAccent => 'Accent color';

  @override
  String get accentDynamic => 'From system';

  @override
  String get accentDynamicSub =>
      'Wallpaper colors on Android 12+, accent color on Windows';

  @override
  String get appearanceAddressBar => 'Address bar';

  @override
  String get barTop => 'Top';

  @override
  String get barBottom => 'Bottom';

  @override
  String get appearanceDensity => 'Density';

  @override
  String get densityComfortable => 'Comfortable';

  @override
  String get densityCompact => 'Compact';

  @override
  String get appearanceEffects => 'Effects';

  @override
  String get privacyProfile => 'Protection profile';

  @override
  String get profileStandard => 'Standard';

  @override
  String get profileStrict => 'Strict';

  @override
  String get profileCustom => 'Custom';

  @override
  String get profileStandardDesc =>
      'Blocks trackers and ads without breaking sites';

  @override
  String get profileStrictDesc =>
      'Maximum protection; some sites may misbehave';

  @override
  String get profileCustomDesc => 'You decide every setting';

  @override
  String get secBlocking => 'Blocking';

  @override
  String get pBlockTrackers => 'Trackers';

  @override
  String get pBlockTrackersSub =>
      'EasyPrivacy, auto-updated with integrity check';

  @override
  String get pBlockAds => 'Ads';

  @override
  String get pBlockAdsSub => 'EasyList';

  @override
  String get secConnection => 'Connection';

  @override
  String get pHttpsOnly => 'HTTPS only';

  @override
  String get pHttpsOnlySub => 'Warn before falling back to HTTP';

  @override
  String get pDoh => 'DNS over HTTPS';

  @override
  String get pDohSub => 'Encrypt DNS lookups (Cloudflare, Quad9, AdGuard)';

  @override
  String get secCookies => 'Cookies & site data';

  @override
  String get pThirdParty => 'Block third-party cookies';

  @override
  String get pClearOnExit => 'Clear on exit';

  @override
  String get pClearOnExitSub => 'Cookies, cache and history of normal tabs';

  @override
  String get pStripParams => 'Clean tracking from links';

  @override
  String get pStripParamsSub => 'utm_*, fbclid, gclid and more';

  @override
  String get secFingerprint => 'Fingerprinting & leaks';

  @override
  String get pGpc => 'Global Privacy Control';

  @override
  String get pGpcSub => 'Tell sites not to sell or share your data';

  @override
  String get pFingerprint => 'Fingerprinting protection';

  @override
  String get pWebRtc => 'Prevent WebRTC IP leaks';

  @override
  String get secApp => 'App';

  @override
  String get pAppLock => 'App lock';

  @override
  String get pAppLockSub => 'Fingerprint, face or Windows Hello';

  @override
  String get pForgetAll => 'Forget everything';

  @override
  String get pForgetAllSub =>
      'Close all tabs and delete history, cookies and cache';

  @override
  String get noTelemetry =>
      'Prism collects no telemetry or analytics. Everything stays on your device.';

  @override
  String get limitedAndroidDoh =>
      'Not available in Android WebView — use the system \"Private DNS\"';

  @override
  String get limitedPartial => 'Partial: limited by the system web engine';

  @override
  String get searchPrivateBadge => 'Private';

  @override
  String get searchCustom => 'Custom URL';

  @override
  String get searchCustomSub => 'Use %s where the query goes';

  @override
  String get searchSuggestions => 'Search suggestions';

  @override
  String get searchSuggestionsSub =>
      'Sent to the search engine only after you start typing';

  @override
  String get permissionsTitle => 'Site permissions';

  @override
  String get permDefaults => 'Defaults';

  @override
  String get permSites => 'Sites';

  @override
  String get permCamera => 'Camera';

  @override
  String get permMicrophone => 'Microphone';

  @override
  String get permLocation => 'Location';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permPopups => 'Pop-ups and redirects';

  @override
  String get decisionAsk => 'Ask';

  @override
  String get decisionAllow => 'Allow';

  @override
  String get decisionBlock => 'Block';

  @override
  String get obWelcomeTitle => 'Welcome to Prism';

  @override
  String get obWelcomeBody =>
      'A fast, private browser. Pick how it looks — you can change it anytime.';

  @override
  String get obTryIt => 'Tap a preview to try it';

  @override
  String get obThemeTitle => 'Theme & color';

  @override
  String get obThemeBody =>
      'Dark theme is the default: easier on the eyes and the battery.';

  @override
  String get obPrivacyTitle => 'Protection level';

  @override
  String get obPrivacyBody =>
      'Trackers and ads are blocked from the first minute. No telemetry, ever.';

  @override
  String get obSearchTitle => 'Search engine';

  @override
  String get obSearchBody =>
      'Suggestions are sent only after you start typing.';

  @override
  String get obNext => 'Next';

  @override
  String get obBack => 'Back';

  @override
  String get obStart => 'Start browsing';

  @override
  String get obSkip => 'Skip';

  @override
  String obStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get windowMinimize => 'Minimize';

  @override
  String get windowMaximize => 'Maximize';

  @override
  String get windowClose => 'Close window';

  @override
  String get colorViolet => 'Prism violet';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorSky => 'Sky blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorPink => 'Pink';

  @override
  String get errorPageTitle => 'Can\'t open this page';

  @override
  String get errorEngineMissingTitle => 'Web engine not found';

  @override
  String get errorEngineMissingBody =>
      'Prism uses the Microsoft Edge WebView2 Runtime to show pages. Install it from microsoft.com and restart Prism.';

  @override
  String get mockNotice => 'Preview: the web engine connects in stage 3';
}
