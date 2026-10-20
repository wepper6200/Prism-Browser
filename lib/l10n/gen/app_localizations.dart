import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prism Browser'**
  String get appTitle;

  /// No description provided for @styleGlass.
  ///
  /// In en, this message translates to:
  /// **'Liquid Glass'**
  String get styleGlass;

  /// No description provided for @styleMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material 3'**
  String get styleMaterial;

  /// No description provided for @styleGlassDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear glass, highlights and floating bars'**
  String get styleGlassDesc;

  /// No description provided for @styleMaterialDesc.
  ///
  /// In en, this message translates to:
  /// **'Tonal colors, living shapes and expressive motion'**
  String get styleMaterialDesc;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @designGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Design system'**
  String get designGalleryTitle;

  /// No description provided for @sectionStyle.
  ///
  /// In en, this message translates to:
  /// **'Interface style'**
  String get sectionStyle;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get sectionTheme;

  /// No description provided for @sectionButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get sectionButtons;

  /// No description provided for @sectionIconButtons.
  ///
  /// In en, this message translates to:
  /// **'Icon buttons'**
  String get sectionIconButtons;

  /// No description provided for @sectionSurfaces.
  ///
  /// In en, this message translates to:
  /// **'Surfaces'**
  String get sectionSurfaces;

  /// No description provided for @sectionTabs.
  ///
  /// In en, this message translates to:
  /// **'Tab cards'**
  String get sectionTabs;

  /// No description provided for @sectionTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get sectionTypography;

  /// No description provided for @sectionControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get sectionControls;

  /// No description provided for @buttonPrimary.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get buttonPrimary;

  /// No description provided for @buttonSecondary.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonSecondary;

  /// No description provided for @buttonGhost.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get buttonGhost;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get actionForward;

  /// No description provided for @actionReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get actionReload;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop loading'**
  String get actionStop;

  /// No description provided for @actionTabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get actionTabs;

  /// No description provided for @actionMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get actionMenu;

  /// No description provided for @actionCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get actionCloseTab;

  /// No description provided for @actionNewTab.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get actionNewTab;

  /// No description provided for @actionShowSheet.
  ///
  /// In en, this message translates to:
  /// **'Show sheet'**
  String get actionShowSheet;

  /// No description provided for @actionHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get actionHome;

  /// No description provided for @actionBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get actionBookmark;

  /// No description provided for @actionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionSettings;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get actionPrevious;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get actionNext;

  /// No description provided for @actionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// No description provided for @actionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get actionOpenFile;

  /// No description provided for @actionClearQuery.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClearQuery;

  /// No description provided for @omniboxHint.
  ///
  /// In en, this message translates to:
  /// **'Search or enter address'**
  String get omniboxHint;

  /// No description provided for @omniboxSearchWith.
  ///
  /// In en, this message translates to:
  /// **'Search with {engine}'**
  String omniboxSearchWith(String engine);

  /// No description provided for @omniboxFill.
  ///
  /// In en, this message translates to:
  /// **'Fill in address bar'**
  String get omniboxFill;

  /// No description provided for @omniboxGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to address'**
  String get omniboxGoTo;

  /// No description provided for @emptyBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get emptyBookmarksTitle;

  /// No description provided for @emptyBookmarksBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on any page to keep it here.'**
  String get emptyBookmarksBody;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History is empty'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Pages you visit in normal tabs appear here. Incognito tabs leave nothing.'**
  String get emptyHistoryBody;

  /// No description provided for @emptyDownloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'No downloads'**
  String get emptyDownloadsTitle;

  /// No description provided for @emptyDownloadsBody.
  ///
  /// In en, this message translates to:
  /// **'Files you download will appear here.'**
  String get emptyDownloadsBody;

  /// No description provided for @suggestionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get suggestionSearch;

  /// No description provided for @suggestionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get suggestionHistory;

  /// No description provided for @suggestionBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get suggestionBookmark;

  /// No description provided for @secureConnection.
  ///
  /// In en, this message translates to:
  /// **'Secure connection'**
  String get secureConnection;

  /// No description provided for @insecureConnection.
  ///
  /// In en, this message translates to:
  /// **'Not secure'**
  String get insecureConnection;

  /// No description provided for @tabsOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tab open} other{{count} tabs open}}'**
  String tabsOpen(int count);

  /// No description provided for @shieldButton.
  ///
  /// In en, this message translates to:
  /// **'Protection: {count} blocked'**
  String shieldButton(int count);

  /// No description provided for @sheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Page actions'**
  String get sheetTitle;

  /// No description provided for @sheetBody.
  ///
  /// In en, this message translates to:
  /// **'Sheets, menus and dialogs share one surface abstraction across styles.'**
  String get sheetBody;

  /// No description provided for @trackersBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No trackers blocked} =1{1 tracker blocked} other{{count} trackers blocked}}'**
  String trackersBlocked(int count);

  /// No description provided for @typeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Fast. Private. Yours.'**
  String get typeDisplay;

  /// No description provided for @typeTitle.
  ///
  /// In en, this message translates to:
  /// **'Title text'**
  String get typeTitle;

  /// No description provided for @typeBody.
  ///
  /// In en, this message translates to:
  /// **'Body text keeps 1.5 line height for comfortable reading on any surface.'**
  String get typeBody;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'LABEL'**
  String get typeLabel;

  /// No description provided for @glassIntensity.
  ///
  /// In en, this message translates to:
  /// **'Glass intensity'**
  String get glassIntensity;

  /// No description provided for @glassAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get glassAuto;

  /// No description provided for @glassManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get glassManual;

  /// No description provided for @glassOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get glassOff;

  /// No description provided for @glassAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Effects are reduced in battery saver, on low-end devices and when the system asks for less transparency.'**
  String get glassAutoHint;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionSub.
  ///
  /// In en, this message translates to:
  /// **'The system setting is always respected too'**
  String get reduceMotionSub;

  /// No description provided for @pinnedTab.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinnedTab;

  /// No description provided for @startTopSites.
  ///
  /// In en, this message translates to:
  /// **'Top sites'**
  String get startTopSites;

  /// No description provided for @startProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection this week'**
  String get startProtection;

  /// No description provided for @statTrackers.
  ///
  /// In en, this message translates to:
  /// **'Trackers'**
  String get statTrackers;

  /// No description provided for @statAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get statAds;

  /// No description provided for @statTime.
  ///
  /// In en, this message translates to:
  /// **'Time saved'**
  String get statTime;

  /// No description provided for @statTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String statTimeValue(int minutes);

  /// No description provided for @incognitoTitle.
  ///
  /// In en, this message translates to:
  /// **'Incognito mode'**
  String get incognitoTitle;

  /// No description provided for @incognitoBody.
  ///
  /// In en, this message translates to:
  /// **'Prism won\'t keep history, cookies or form data from these tabs, and nothing is written to disk. Downloads and bookmarks you save stay. Websites and your network can still see your traffic.'**
  String get incognitoBody;

  /// No description provided for @tabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabsTitle;

  /// No description provided for @tabsNormal.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabsNormal;

  /// No description provided for @tabsIncognito.
  ///
  /// In en, this message translates to:
  /// **'Incognito'**
  String get tabsIncognito;

  /// No description provided for @tabsAllGroups.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabsAllGroups;

  /// No description provided for @tabsUnloaded.
  ///
  /// In en, this message translates to:
  /// **'Unloaded to save memory'**
  String get tabsUnloaded;

  /// No description provided for @tabsCloseAll.
  ///
  /// In en, this message translates to:
  /// **'Close all'**
  String get tabsCloseAll;

  /// No description provided for @tabsEmptyIncognito.
  ///
  /// In en, this message translates to:
  /// **'No incognito tabs'**
  String get tabsEmptyIncognito;

  /// No description provided for @tabsEmptyIncognitoBody.
  ///
  /// In en, this message translates to:
  /// **'Incognito tabs keep nothing after you close them.'**
  String get tabsEmptyIncognitoBody;

  /// No description provided for @menuNewIncognito.
  ///
  /// In en, this message translates to:
  /// **'New incognito tab'**
  String get menuNewIncognito;

  /// No description provided for @menuBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get menuBookmarks;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @menuDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get menuDownloads;

  /// No description provided for @menuFindInPage.
  ///
  /// In en, this message translates to:
  /// **'Find in page'**
  String get menuFindInPage;

  /// No description provided for @menuReader.
  ///
  /// In en, this message translates to:
  /// **'Reader mode'**
  String get menuReader;

  /// No description provided for @menuDesktopSite.
  ///
  /// In en, this message translates to:
  /// **'Desktop site'**
  String get menuDesktopSite;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @menuSavePdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get menuSavePdf;

  /// No description provided for @menuZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get menuZoom;

  /// No description provided for @menuZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get menuZoomOut;

  /// No description provided for @menuZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get menuZoomIn;

  /// No description provided for @menuForgetAll.
  ///
  /// In en, this message translates to:
  /// **'Forget everything'**
  String get menuForgetAll;

  /// No description provided for @menuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tab'**
  String get menuDuplicate;

  /// No description provided for @menuPin.
  ///
  /// In en, this message translates to:
  /// **'Pin tab'**
  String get menuPin;

  /// No description provided for @findCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String findCount(int current, int total);

  /// No description provided for @shieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Protection on {host}'**
  String shieldTitle(String host);

  /// No description provided for @shieldOn.
  ///
  /// In en, this message translates to:
  /// **'Trackers and ads are blocked'**
  String get shieldOn;

  /// No description provided for @shieldOnSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off only if the site is broken'**
  String get shieldOnSub;

  /// No description provided for @statCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get statCookies;

  /// No description provided for @shieldBlockedList.
  ///
  /// In en, this message translates to:
  /// **'Blocked requests'**
  String get shieldBlockedList;

  /// No description provided for @kindTracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get kindTracker;

  /// No description provided for @kindAd.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get kindAd;

  /// No description provided for @requestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request} other{{count} requests}}'**
  String requestsCount(int count);

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksSearch.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks'**
  String get bookmarksSearch;

  /// No description provided for @bookmarksFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get bookmarksFolders;

  /// No description provided for @bookmarksUnsorted.
  ///
  /// In en, this message translates to:
  /// **'Other bookmarks'**
  String get bookmarksUnsorted;

  /// No description provided for @bookmarksInFolder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bookmark} other{{count} bookmarks}}'**
  String bookmarksInFolder(int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get historySearch;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get historyEarlier;

  /// No description provided for @historyClear.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get historyClear;

  /// No description provided for @clearRangeHour.
  ///
  /// In en, this message translates to:
  /// **'Last hour'**
  String get clearRangeHour;

  /// No description provided for @clearRangeDay.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get clearRangeDay;

  /// No description provided for @clearRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get clearRangeWeek;

  /// No description provided for @clearRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get clearRangeAll;

  /// No description provided for @clearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'History, cookies and cache for the selected period will be deleted. This can\'t be undone.'**
  String get clearHistoryBody;

  /// No description provided for @downloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadPaused;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed — network error'**
  String get downloadFailed;

  /// No description provided for @downloadDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get downloadDone;

  /// No description provided for @downloadProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String downloadProgress(String done, String total);

  /// No description provided for @unitKB.
  ///
  /// In en, this message translates to:
  /// **'{v} KB'**
  String unitKB(String v);

  /// No description provided for @unitMB.
  ///
  /// In en, this message translates to:
  /// **'{v} MB'**
  String unitMB(String v);

  /// No description provided for @unitGB.
  ///
  /// In en, this message translates to:
  /// **'{v} GB'**
  String unitGB(String v);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSub.
  ///
  /// In en, this message translates to:
  /// **'Style, theme, color, address bar'**
  String get settingsAppearanceSub;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Trackers, cookies, HTTPS, app lock'**
  String get settingsPrivacySub;

  /// No description provided for @settingsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search engine'**
  String get settingsSearch;

  /// No description provided for @settingsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Site permissions'**
  String get settingsPermissions;

  /// No description provided for @settingsPermissionsSub.
  ///
  /// In en, this message translates to:
  /// **'Camera, microphone, location, notifications'**
  String get settingsPermissionsSub;

  /// No description provided for @settingsDefaultBrowser.
  ///
  /// In en, this message translates to:
  /// **'Default browser'**
  String get settingsDefaultBrowser;

  /// No description provided for @settingsDefaultBrowserSub.
  ///
  /// In en, this message translates to:
  /// **'Open links from other apps in Prism'**
  String get settingsDefaultBrowserSub;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Prism'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSub.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · no telemetry'**
  String settingsAboutSub(String version);

  /// No description provided for @settingsDesign.
  ///
  /// In en, this message translates to:
  /// **'Design system'**
  String get settingsDesign;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @appearanceStyle.
  ///
  /// In en, this message translates to:
  /// **'Interface style'**
  String get appearanceStyle;

  /// No description provided for @appearanceAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get appearanceAccent;

  /// No description provided for @accentDynamic.
  ///
  /// In en, this message translates to:
  /// **'From system'**
  String get accentDynamic;

  /// No description provided for @accentDynamicSub.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper colors on Android 12+, accent color on Windows'**
  String get accentDynamicSub;

  /// No description provided for @appearanceAddressBar.
  ///
  /// In en, this message translates to:
  /// **'Address bar'**
  String get appearanceAddressBar;

  /// No description provided for @barTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get barTop;

  /// No description provided for @barBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get barBottom;

  /// No description provided for @appearanceDensity.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get appearanceDensity;

  /// No description provided for @densityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get densityComfortable;

  /// No description provided for @densityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get densityCompact;

  /// No description provided for @appearanceEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get appearanceEffects;

  /// No description provided for @privacyProfile.
  ///
  /// In en, this message translates to:
  /// **'Protection profile'**
  String get privacyProfile;

  /// No description provided for @profileStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get profileStandard;

  /// No description provided for @profileStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get profileStrict;

  /// No description provided for @profileCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get profileCustom;

  /// No description provided for @profileStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Blocks trackers and ads without breaking sites'**
  String get profileStandardDesc;

  /// No description provided for @profileStrictDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum protection; some sites may misbehave'**
  String get profileStrictDesc;

  /// No description provided for @profileCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'You decide every setting'**
  String get profileCustomDesc;

  /// No description provided for @secBlocking.
  ///
  /// In en, this message translates to:
  /// **'Blocking'**
  String get secBlocking;

  /// No description provided for @pBlockTrackers.
  ///
  /// In en, this message translates to:
  /// **'Trackers'**
  String get pBlockTrackers;

  /// No description provided for @pBlockTrackersSub.
  ///
  /// In en, this message translates to:
  /// **'EasyPrivacy, auto-updated with integrity check'**
  String get pBlockTrackersSub;

  /// No description provided for @pBlockAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get pBlockAds;

  /// No description provided for @pBlockAdsSub.
  ///
  /// In en, this message translates to:
  /// **'EasyList'**
  String get pBlockAdsSub;

  /// No description provided for @secConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get secConnection;

  /// No description provided for @pHttpsOnly.
  ///
  /// In en, this message translates to:
  /// **'HTTPS only'**
  String get pHttpsOnly;

  /// No description provided for @pHttpsOnlySub.
  ///
  /// In en, this message translates to:
  /// **'Warn before falling back to HTTP'**
  String get pHttpsOnlySub;

  /// No description provided for @pDoh.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get pDoh;

  /// No description provided for @pDohSub.
  ///
  /// In en, this message translates to:
  /// **'Encrypt DNS lookups (Cloudflare, Quad9, AdGuard)'**
  String get pDohSub;

  /// No description provided for @secCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies & site data'**
  String get secCookies;

  /// No description provided for @pThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Block third-party cookies'**
  String get pThirdParty;

  /// No description provided for @pClearOnExit.
  ///
  /// In en, this message translates to:
  /// **'Clear on exit'**
  String get pClearOnExit;

  /// No description provided for @pClearOnExitSub.
  ///
  /// In en, this message translates to:
  /// **'Cookies, cache and history of normal tabs'**
  String get pClearOnExitSub;

  /// No description provided for @pStripParams.
  ///
  /// In en, this message translates to:
  /// **'Clean tracking from links'**
  String get pStripParams;

  /// No description provided for @pStripParamsSub.
  ///
  /// In en, this message translates to:
  /// **'utm_*, fbclid, gclid and more'**
  String get pStripParamsSub;

  /// No description provided for @secFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprinting & leaks'**
  String get secFingerprint;

  /// No description provided for @pGpc.
  ///
  /// In en, this message translates to:
  /// **'Global Privacy Control'**
  String get pGpc;

  /// No description provided for @pGpcSub.
  ///
  /// In en, this message translates to:
  /// **'Tell sites not to sell or share your data'**
  String get pGpcSub;

  /// No description provided for @pFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprinting protection'**
  String get pFingerprint;

  /// No description provided for @pWebRtc.
  ///
  /// In en, this message translates to:
  /// **'Prevent WebRTC IP leaks'**
  String get pWebRtc;

  /// No description provided for @secApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get secApp;

  /// No description provided for @pAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get pAppLock;

  /// No description provided for @pAppLockSub.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint, face or Windows Hello'**
  String get pAppLockSub;

  /// No description provided for @pForgetAll.
  ///
  /// In en, this message translates to:
  /// **'Forget everything'**
  String get pForgetAll;

  /// No description provided for @pForgetAllSub.
  ///
  /// In en, this message translates to:
  /// **'Close all tabs and delete history, cookies and cache'**
  String get pForgetAllSub;

  /// No description provided for @noTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Prism collects no telemetry or analytics. Everything stays on your device.'**
  String get noTelemetry;

  /// No description provided for @limitedAndroidDoh.
  ///
  /// In en, this message translates to:
  /// **'Not available in Android WebView — use the system \"Private DNS\"'**
  String get limitedAndroidDoh;

  /// No description provided for @limitedPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial: limited by the system web engine'**
  String get limitedPartial;

  /// No description provided for @searchPrivateBadge.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get searchPrivateBadge;

  /// No description provided for @searchCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom URL'**
  String get searchCustom;

  /// No description provided for @searchCustomSub.
  ///
  /// In en, this message translates to:
  /// **'Use %s where the query goes'**
  String get searchCustomSub;

  /// No description provided for @customSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom search engine'**
  String get customSearchTitle;

  /// No description provided for @customSearchName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customSearchName;

  /// No description provided for @customSearchNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, SearXNG'**
  String get customSearchNameHint;

  /// No description provided for @customSearchUrl.
  ///
  /// In en, this message translates to:
  /// **'Search URL'**
  String get customSearchUrl;

  /// No description provided for @customSearchUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Put %s where the query goes. Example: https://searx.be/search?q=%s'**
  String get customSearchUrlHelp;

  /// No description provided for @customErrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a search URL'**
  String get customErrEmpty;

  /// No description provided for @customErrUrl.
  ///
  /// In en, this message translates to:
  /// **'Use an address like https://site/path?q=%s'**
  String get customErrUrl;

  /// No description provided for @customErrNoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add %s where the query should go'**
  String get customErrNoPlaceholder;

  /// No description provided for @customErrMany.
  ///
  /// In en, this message translates to:
  /// **'%s must appear exactly once'**
  String get customErrMany;

  /// No description provided for @customInsecure.
  ///
  /// In en, this message translates to:
  /// **'No HTTPS: your searches will be visible on the network'**
  String get customInsecure;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @searchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Search suggestions'**
  String get searchSuggestions;

  /// No description provided for @searchSuggestionsSub.
  ///
  /// In en, this message translates to:
  /// **'Sent to the search engine only after you start typing'**
  String get searchSuggestionsSub;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Site permissions'**
  String get permissionsTitle;

  /// No description provided for @permDefaults.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get permDefaults;

  /// No description provided for @permSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get permSites;

  /// No description provided for @permCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permCamera;

  /// No description provided for @permMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permMicrophone;

  /// No description provided for @permLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permLocation;

  /// No description provided for @permNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifications;

  /// No description provided for @permPopups.
  ///
  /// In en, this message translates to:
  /// **'Pop-ups and redirects'**
  String get permPopups;

  /// No description provided for @decisionAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get decisionAsk;

  /// No description provided for @decisionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get decisionAllow;

  /// No description provided for @decisionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get decisionBlock;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Prism'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A fast, private browser. Pick how it looks — you can change it anytime.'**
  String get obWelcomeBody;

  /// No description provided for @obTryIt.
  ///
  /// In en, this message translates to:
  /// **'Tap a preview to try it'**
  String get obTryIt;

  /// No description provided for @obThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme & color'**
  String get obThemeTitle;

  /// No description provided for @obThemeBody.
  ///
  /// In en, this message translates to:
  /// **'Dark theme is the default: easier on the eyes and the battery.'**
  String get obThemeBody;

  /// No description provided for @obPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Protection level'**
  String get obPrivacyTitle;

  /// No description provided for @obPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Trackers and ads are blocked from the first minute. No telemetry, ever.'**
  String get obPrivacyBody;

  /// No description provided for @obSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search engine'**
  String get obSearchTitle;

  /// No description provided for @obSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Suggestions are sent only after you start typing.'**
  String get obSearchBody;

  /// No description provided for @obNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get obNext;

  /// No description provided for @obBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get obBack;

  /// No description provided for @obStart.
  ///
  /// In en, this message translates to:
  /// **'Start browsing'**
  String get obStart;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String obStep(int step, int total);

  /// No description provided for @windowMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get windowMinimize;

  /// No description provided for @windowMaximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get windowMaximize;

  /// No description provided for @windowClose.
  ///
  /// In en, this message translates to:
  /// **'Close window'**
  String get windowClose;

  /// No description provided for @colorViolet.
  ///
  /// In en, this message translates to:
  /// **'Prism violet'**
  String get colorViolet;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get colorSky;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @errorPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open this page'**
  String get errorPageTitle;

  /// No description provided for @errorEngineMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Web engine not found'**
  String get errorEngineMissingTitle;

  /// No description provided for @errorEngineMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Prism uses the Microsoft Edge WebView2 Runtime to show pages. Install it from microsoft.com and restart Prism.'**
  String get errorEngineMissingBody;

  /// No description provided for @mockNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview: the web engine connects in stage 3'**
  String get mockNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
