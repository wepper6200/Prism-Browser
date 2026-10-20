// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Prism Browser';

  @override
  String get styleGlass => 'Liquid Glass';

  @override
  String get styleMaterial => 'Material 3';

  @override
  String get styleGlassDesc => 'Прозрачное стекло, блики и плавающие панели';

  @override
  String get styleMaterialDesc =>
      'Тональные цвета, живые формы и выразительная анимация';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get designGalleryTitle => 'Дизайн-система';

  @override
  String get sectionStyle => 'Стиль интерфейса';

  @override
  String get sectionTheme => 'Тема';

  @override
  String get sectionButtons => 'Кнопки';

  @override
  String get sectionIconButtons => 'Кнопки-иконки';

  @override
  String get sectionSurfaces => 'Поверхности';

  @override
  String get sectionTabs => 'Карточки вкладок';

  @override
  String get sectionTypography => 'Типографика';

  @override
  String get sectionControls => 'Элементы управления';

  @override
  String get buttonPrimary => 'Открыть';

  @override
  String get buttonSecondary => 'Отмена';

  @override
  String get buttonGhost => 'Ещё';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionForward => 'Вперёд';

  @override
  String get actionReload => 'Обновить';

  @override
  String get actionStop => 'Остановить загрузку';

  @override
  String get actionTabs => 'Вкладки';

  @override
  String get actionMenu => 'Меню';

  @override
  String get actionCloseTab => 'Закрыть вкладку';

  @override
  String get actionNewTab => 'Новая вкладка';

  @override
  String get actionShowSheet => 'Показать лист';

  @override
  String get actionHome => 'Главная';

  @override
  String get actionBookmark => 'В закладки';

  @override
  String get actionSettings => 'Настройки';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionPrevious => 'Предыдущее совпадение';

  @override
  String get actionNext => 'Следующее совпадение';

  @override
  String get actionPause => 'Пауза';

  @override
  String get actionResume => 'Продолжить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionOpenFile => 'Открыть файл';

  @override
  String get actionClearQuery => 'Очистить';

  @override
  String get omniboxHint => 'Поиск или адрес';

  @override
  String omniboxSearchWith(String engine) {
    return 'Искать в $engine';
  }

  @override
  String get omniboxFill => 'Подставить в адресную строку';

  @override
  String get omniboxGoTo => 'Перейти по адресу';

  @override
  String get emptyBookmarksTitle => 'Закладок пока нет';

  @override
  String get emptyBookmarksBody =>
      'Нажмите на звёздочку на любой странице, чтобы сохранить её здесь.';

  @override
  String get emptyHistoryTitle => 'История пуста';

  @override
  String get emptyHistoryBody =>
      'Здесь появятся страницы из обычных вкладок. Вкладки инкогнито ничего не оставляют.';

  @override
  String get emptyDownloadsTitle => 'Загрузок нет';

  @override
  String get emptyDownloadsBody => 'Здесь появятся скачанные файлы.';

  @override
  String get suggestionSearch => 'Поиск';

  @override
  String get suggestionHistory => 'История';

  @override
  String get suggestionBookmark => 'Закладка';

  @override
  String get secureConnection => 'Защищённое соединение';

  @override
  String get insecureConnection => 'Небезопасное соединение';

  @override
  String tabsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count вкладки',
      many: 'Открыто $count вкладок',
      few: 'Открыто $count вкладки',
      one: 'Открыта $count вкладка',
    );
    return '$_temp0';
  }

  @override
  String shieldButton(int count) {
    return 'Защита: заблокировано $count';
  }

  @override
  String get sheetTitle => 'Действия со страницей';

  @override
  String get sheetBody =>
      'Листы, меню и диалоги используют одну абстракцию поверхности во всех стилях.';

  @override
  String trackersBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заблокировано $count трекера',
      many: 'Заблокировано $count трекеров',
      few: 'Заблокировано $count трекера',
      one: 'Заблокирован $count трекер',
      zero: 'Трекеры не найдены',
    );
    return '$_temp0';
  }

  @override
  String get typeDisplay => 'Быстро. Приватно. Ваше.';

  @override
  String get typeTitle => 'Заголовок';

  @override
  String get typeBody =>
      'Основной текст с межстрочным интервалом 1,5 удобно читается на любой поверхности.';

  @override
  String get typeLabel => 'МЕТКА';

  @override
  String get glassIntensity => 'Интенсивность стекла';

  @override
  String get glassAuto => 'Авто';

  @override
  String get glassManual => 'Вручную';

  @override
  String get glassOff => 'Выкл.';

  @override
  String get glassAutoHint =>
      'Эффекты упрощаются в режиме экономии заряда, на слабых устройствах и при системном «уменьшить прозрачность».';

  @override
  String get reduceMotion => 'Уменьшить анимации';

  @override
  String get reduceMotionSub => 'Системная настройка учитывается всегда';

  @override
  String get pinnedTab => 'Закреплена';

  @override
  String get startTopSites => 'Часто посещаемые';

  @override
  String get startProtection => 'Защита за неделю';

  @override
  String get statTrackers => 'Трекеры';

  @override
  String get statAds => 'Реклама';

  @override
  String get statTime => 'Сэкономлено';

  @override
  String statTimeValue(int minutes) {
    return '$minutes мин';
  }

  @override
  String get incognitoTitle => 'Режим инкогнито';

  @override
  String get incognitoBody =>
      'Prism не сохранит историю, куки и данные форм этих вкладок и ничего не запишет на диск. Сохранённые загрузки и закладки останутся. Сайты и ваша сеть по-прежнему видят трафик.';

  @override
  String get tabsTitle => 'Вкладки';

  @override
  String get tabsNormal => 'Вкладки';

  @override
  String get tabsIncognito => 'Инкогнито';

  @override
  String get tabsAllGroups => 'Все';

  @override
  String get tabsUnloaded => 'Выгружена для экономии памяти';

  @override
  String get tabsCloseAll => 'Закрыть все';

  @override
  String get tabsEmptyIncognito => 'Нет вкладок инкогнито';

  @override
  String get tabsEmptyIncognitoBody =>
      'После закрытия вкладки инкогнито от неё ничего не остаётся.';

  @override
  String get menuNewIncognito => 'Новая вкладка инкогнито';

  @override
  String get menuBookmarks => 'Закладки';

  @override
  String get menuHistory => 'История';

  @override
  String get menuDownloads => 'Загрузки';

  @override
  String get menuFindInPage => 'Найти на странице';

  @override
  String get menuReader => 'Режим чтения';

  @override
  String get menuDesktopSite => 'Версия для ПК';

  @override
  String get menuShare => 'Поделиться';

  @override
  String get menuSavePdf => 'Сохранить в PDF';

  @override
  String get menuZoom => 'Масштаб';

  @override
  String get menuZoomOut => 'Уменьшить';

  @override
  String get menuZoomIn => 'Увеличить';

  @override
  String get menuForgetAll => 'Забыть всё';

  @override
  String get menuDuplicate => 'Дублировать вкладку';

  @override
  String get menuPin => 'Закрепить вкладку';

  @override
  String findCount(int current, int total) {
    return '$current из $total';
  }

  @override
  String shieldTitle(String host) {
    return 'Защита на $host';
  }

  @override
  String get shieldOn => 'Трекеры и реклама блокируются';

  @override
  String get shieldOnSub => 'Отключайте, только если сайт сломался';

  @override
  String get statCookies => 'Куки';

  @override
  String get shieldBlockedList => 'Заблокированные запросы';

  @override
  String get kindTracker => 'Трекер';

  @override
  String get kindAd => 'Реклама';

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запроса',
      many: '$count запросов',
      few: '$count запроса',
      one: '$count запрос',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksTitle => 'Закладки';

  @override
  String get bookmarksSearch => 'Поиск в закладках';

  @override
  String get bookmarksFolders => 'Папки';

  @override
  String get bookmarksUnsorted => 'Другие закладки';

  @override
  String bookmarksInFolder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count закладки',
      many: '$count закладок',
      few: '$count закладки',
      one: '$count закладка',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'История';

  @override
  String get historySearch => 'Поиск в истории';

  @override
  String get historyToday => 'Сегодня';

  @override
  String get historyYesterday => 'Вчера';

  @override
  String get historyEarlier => 'Ранее';

  @override
  String get historyClear => 'Очистить историю';

  @override
  String get clearRangeHour => 'За последний час';

  @override
  String get clearRangeDay => 'За сутки';

  @override
  String get clearRangeWeek => 'За неделю';

  @override
  String get clearRangeAll => 'За всё время';

  @override
  String get clearHistoryBody =>
      'История, куки и кэш за выбранный период будут удалены. Отменить это нельзя.';

  @override
  String get downloadsTitle => 'Загрузки';

  @override
  String get downloadPaused => 'Пауза';

  @override
  String get downloadFailed => 'Ошибка сети';

  @override
  String get downloadDone => 'Загружено';

  @override
  String downloadProgress(String done, String total) {
    return '$done из $total';
  }

  @override
  String unitKB(String v) {
    return '$v КБ';
  }

  @override
  String unitMB(String v) {
    return '$v МБ';
  }

  @override
  String unitGB(String v) {
    return '$v ГБ';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsAppearanceSub => 'Стиль, тема, цвет, адресная строка';

  @override
  String get settingsPrivacy => 'Приватность и безопасность';

  @override
  String get settingsPrivacySub =>
      'Трекеры, куки, HTTPS, блокировка приложения';

  @override
  String get settingsSearch => 'Поисковая система';

  @override
  String get settingsPermissions => 'Разрешения сайтов';

  @override
  String get settingsPermissionsSub =>
      'Камера, микрофон, местоположение, уведомления';

  @override
  String get settingsDefaultBrowser => 'Браузер по умолчанию';

  @override
  String get settingsDefaultBrowserSub =>
      'Открывать ссылки из других приложений в Prism';

  @override
  String get settingsAbout => 'О Prism';

  @override
  String settingsAboutSub(String version) {
    return 'Версия $version · без телеметрии';
  }

  @override
  String get settingsDesign => 'Дизайн-система';

  @override
  String get settingsGeneral => 'Основные';

  @override
  String get appearanceStyle => 'Стиль интерфейса';

  @override
  String get appearanceAccent => 'Акцентный цвет';

  @override
  String get accentDynamic => 'Из системы';

  @override
  String get accentDynamicSub =>
      'Цвета обоев на Android 12+, акцентный цвет в Windows';

  @override
  String get appearanceAddressBar => 'Адресная строка';

  @override
  String get barTop => 'Сверху';

  @override
  String get barBottom => 'Снизу';

  @override
  String get appearanceDensity => 'Плотность';

  @override
  String get densityComfortable => 'Обычная';

  @override
  String get densityCompact => 'Компактная';

  @override
  String get appearanceEffects => 'Эффекты';

  @override
  String get privacyProfile => 'Профиль защиты';

  @override
  String get profileStandard => 'Стандартный';

  @override
  String get profileStrict => 'Строгий';

  @override
  String get profileCustom => 'Свой';

  @override
  String get profileStandardDesc =>
      'Блокирует трекеры и рекламу, не ломая сайты';

  @override
  String get profileStrictDesc =>
      'Максимум защиты; некоторые сайты могут работать хуже';

  @override
  String get profileCustomDesc => 'Вы сами настраиваете каждый пункт';

  @override
  String get secBlocking => 'Блокировка';

  @override
  String get pBlockTrackers => 'Трекеры';

  @override
  String get pBlockTrackersSub =>
      'EasyPrivacy, автообновление с проверкой целостности';

  @override
  String get pBlockAds => 'Реклама';

  @override
  String get pBlockAdsSub => 'EasyList';

  @override
  String get secConnection => 'Соединение';

  @override
  String get pHttpsOnly => 'Только HTTPS';

  @override
  String get pHttpsOnlySub => 'Предупреждать перед переходом на HTTP';

  @override
  String get pDoh => 'DNS-over-HTTPS';

  @override
  String get pDohSub => 'Шифровать DNS-запросы (Cloudflare, Quad9, AdGuard)';

  @override
  String get secCookies => 'Куки и данные сайтов';

  @override
  String get pThirdParty => 'Блокировать сторонние куки';

  @override
  String get pClearOnExit => 'Очищать при выходе';

  @override
  String get pClearOnExitSub => 'Куки, кэш и история обычных вкладок';

  @override
  String get pStripParams => 'Очищать ссылки от трекинга';

  @override
  String get pStripParamsSub => 'utm_*, fbclid, gclid и другие';

  @override
  String get secFingerprint => 'Отпечаток и утечки';

  @override
  String get pGpc => 'Global Privacy Control';

  @override
  String get pGpcSub => 'Сообщать сайтам о запрете продажи данных';

  @override
  String get pFingerprint => 'Защита от fingerprinting';

  @override
  String get pWebRtc => 'Блокировать утечку IP через WebRTC';

  @override
  String get secApp => 'Приложение';

  @override
  String get pAppLock => 'Блокировка приложения';

  @override
  String get pAppLockSub => 'Отпечаток пальца, лицо или Windows Hello';

  @override
  String get pForgetAll => 'Забыть всё';

  @override
  String get pForgetAllSub => 'Закрыть вкладки и удалить историю, куки и кэш';

  @override
  String get noTelemetry =>
      'Prism не собирает телеметрию и аналитику. Все данные хранятся только на устройстве.';

  @override
  String get limitedAndroidDoh =>
      'Недоступно в Android WebView — используйте системный «Частный DNS»';

  @override
  String get limitedPartial =>
      'Работает частично: ограничено системным веб-движком';

  @override
  String get searchPrivateBadge => 'Приватный';

  @override
  String get searchCustom => 'Свой URL';

  @override
  String get searchCustomSub => 'Поставьте %s на место запроса';

  @override
  String get customSearchTitle => 'Своя поисковая система';

  @override
  String get customSearchName => 'Название';

  @override
  String get customSearchNameHint => 'Например, SearXNG';

  @override
  String get customSearchUrl => 'Адрес поиска';

  @override
  String get customSearchUrlHelp =>
      'Поставьте %s туда, где должен стоять запрос. Пример: https://searx.be/search?q=%s';

  @override
  String get customErrEmpty => 'Введите адрес поиска';

  @override
  String get customErrUrl => 'Нужен адрес вида https://сайт/путь?q=%s';

  @override
  String get customErrNoPlaceholder =>
      'Добавьте %s в то место, куда подставляется запрос';

  @override
  String get customErrMany => '%s должен встречаться ровно один раз';

  @override
  String get customInsecure =>
      'Адрес без HTTPS: ваши запросы будут видны в сети';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get searchSuggestions => 'Поисковые подсказки';

  @override
  String get searchSuggestionsSub =>
      'Отправляются поисковику только после начала ввода';

  @override
  String get permissionsTitle => 'Разрешения сайтов';

  @override
  String get permDefaults => 'По умолчанию';

  @override
  String get permSites => 'Сайты';

  @override
  String get permCamera => 'Камера';

  @override
  String get permMicrophone => 'Микрофон';

  @override
  String get permLocation => 'Местоположение';

  @override
  String get permNotifications => 'Уведомления';

  @override
  String get permPopups => 'Всплывающие окна и переадресация';

  @override
  String get decisionAsk => 'Спрашивать';

  @override
  String get decisionAllow => 'Разрешить';

  @override
  String get decisionBlock => 'Запретить';

  @override
  String get obWelcomeTitle => 'Добро пожаловать в Prism';

  @override
  String get obWelcomeBody =>
      'Быстрый и приватный браузер. Выберите, как он будет выглядеть, — это можно изменить в любой момент.';

  @override
  String get obTryIt => 'Нажмите на превью, чтобы попробовать';

  @override
  String get obThemeTitle => 'Тема и цвет';

  @override
  String get obThemeBody => 'Тёмная тема по умолчанию бережёт глаза и заряд.';

  @override
  String get obPrivacyTitle => 'Уровень защиты';

  @override
  String get obPrivacyBody =>
      'Трекеры и реклама блокируются с первой минуты. Никакой телеметрии.';

  @override
  String get obSearchTitle => 'Поисковая система';

  @override
  String get obSearchBody =>
      'Подсказки отправляются поисковику только после того, как вы начали печатать.';

  @override
  String get obNext => 'Далее';

  @override
  String get obBack => 'Назад';

  @override
  String get obStart => 'Начать';

  @override
  String get obSkip => 'Пропустить';

  @override
  String obStep(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get windowMinimize => 'Свернуть';

  @override
  String get windowMaximize => 'Развернуть';

  @override
  String get windowClose => 'Закрыть окно';

  @override
  String get colorViolet => 'Фиолетовый Prism';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorSky => 'Голубой';

  @override
  String get colorGreen => 'Зелёный';

  @override
  String get colorAmber => 'Янтарный';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorRose => 'Малиновый';

  @override
  String get colorPink => 'Розовый';

  @override
  String get errorPageTitle => 'Не удалось открыть страницу';

  @override
  String get errorEngineMissingTitle => 'Не найден веб-движок';

  @override
  String get errorEngineMissingBody =>
      'Для показа страниц Prism использует Microsoft Edge WebView2 Runtime. Установите его с сайта microsoft.com и перезапустите Prism.';

  @override
  String get mockNotice => 'Предпросмотр: веб-движок подключается на этапе 3';

  @override
  String get actionMore => 'Ещё';

  @override
  String get actionRename => 'Переименовать';

  @override
  String get bookmarksDeleteFolder => 'Удалить папку';

  @override
  String get bookmarksDeleteFolderSub =>
      'Закладки из неё перейдут в «Без папки»';

  @override
  String get bookmarksEdit => 'Изменить закладку';

  @override
  String get bookmarksFieldFolder => 'Папка';

  @override
  String get bookmarksFieldTitle => 'Название';

  @override
  String get bookmarksFolderEmpty => 'В папке пока пусто';

  @override
  String get bookmarksFolderName => 'Название папки';

  @override
  String get bookmarksNewFolder => 'Новая папка';

  @override
  String get downloadCancel => 'Отменить загрузку';

  @override
  String get downloadOpenFailed => 'Не удалось открыть файл';

  @override
  String get downloadRemoveFromList => 'Убрать из списка (файл останется)';

  @override
  String downloadStarted(Object name) {
    return 'Загружается: $name';
  }

  @override
  String get emptySearchBody => 'Попробуйте другой запрос.';

  @override
  String get emptySearchTitle => 'Ничего не найдено';

  @override
  String get historyRemoveEntry => 'Удалить из истории';

  @override
  String get tabsDeleteGroup => 'Удалить группу';

  @override
  String get tabsDeleteGroupSub => 'Вкладки останутся открытыми, без группы';

  @override
  String get tabsGroup => 'Группа';

  @override
  String get tabsGroupName => 'Название группы';

  @override
  String get tabsNewGroup => 'Новая группа';

  @override
  String get tabsNoGroup => 'Без группы';

  @override
  String get menuBookmarked => 'В закладках';

  @override
  String get menuBookmarkedSub => 'Нажмите, чтобы удалить';

  @override
  String get bookmarkAdded => 'Добавлено в закладки';

  @override
  String get bookmarkRemoved => 'Удалено из закладок';

  @override
  String get incognitoMark => 'Режим инкогнито';

  @override
  String get incognitoCookiesShared =>
      'На Android веб-движок (WebView) хранит куки общими для всех вкладок приложения. Prism не сохраняет в инкогнито историю, вкладки, кэш и список загрузок, но сайты могут видеть куки, которые вы получили в обычных вкладках.';
}
