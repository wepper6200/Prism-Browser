import '../../domain/browser/models.dart';

/// Stage-2 fixtures. Replaced by drift repositories and the real engine in
/// stages 3-4; kept afterwards for tests and showcase boards.
abstract final class MockData {
  static const groups = [
    TabGroup(id: 'g-work', name: 'Работа', color: 0xFF38BDF8),
    TabGroup(id: 'g-trip', name: 'Поездка', color: 0xFFF472B6),
  ];

  static const tabs = [
    BrowserTab(
      id: 't1',
      title: 'Призма — Википедия',
      url: 'https://ru.wikipedia.org/wiki/Призма_(оптика)',
      pinned: true,
    ),
    BrowserTab(
      id: 't2',
      title: 'DuckDuckGo — приватный поиск',
      url: 'https://duckduckgo.com/?q=prism',
    ),
    BrowserTab(
      id: 't3',
      title: 'Flutter — Build apps for any screen',
      url: 'https://flutter.dev',
      groupId: 'g-work',
    ),
    BrowserTab(
      id: 't4',
      title: 'GitHub — prism-browser',
      url: 'https://github.com/prism-browser',
      groupId: 'g-work',
      loaded: false,
    ),
    BrowserTab(
      id: 't5',
      title: 'Билеты в Калининград',
      url: 'https://www.rzd.ru',
      groupId: 'g-trip',
      loaded: false,
    ),
    BrowserTab(id: 't6', title: 'Новая вкладка', url: ''),
  ];

  static const incognitoTabs = [
    BrowserTab(
      id: 'i1',
      title: 'Подарок на день рождения',
      url: 'https://market.yandex.ru',
      incognito: true,
    ),
  ];

  static const folders = [
    BookmarkFolder(id: 'f-dev', name: 'Разработка'),
    BookmarkFolder(id: 'f-read', name: 'Почитать позже'),
    BookmarkFolder(id: 'f-trip', name: 'Путешествия'),
  ];

  static const bookmarks = [
    Bookmark(
      id: 'b1',
      title: 'Flutter documentation',
      url: 'https://docs.flutter.dev',
      folderId: 'f-dev',
    ),
    Bookmark(
      id: 'b2',
      title: 'Material 3',
      url: 'https://m3.material.io',
      folderId: 'f-dev',
    ),
    Bookmark(
      id: 'b3',
      title: 'Призма (оптика) — Википедия',
      url: 'https://ru.wikipedia.org/wiki/Призма_(оптика)',
    ),
    Bookmark(id: 'b4', title: 'Хабр', url: 'https://habr.com'),
    Bookmark(
      id: 'b5',
      title: 'EFF — Surveillance Self-Defense',
      url: 'https://ssd.eff.org',
      folderId: 'f-read',
    ),
  ];

  static List<HistoryEntry> history(DateTime now) {
    HistoryEntry h(String id, String title, String url, Duration ago) =>
        HistoryEntry(
          id: id,
          title: title,
          url: url,
          visitedAt: now.subtract(ago),
        );
    return [
      h(
        'h1',
        'Призма — Википедия',
        'https://ru.wikipedia.org/wiki/Призма',
        const Duration(minutes: 4),
      ),
      h(
        'h2',
        'prism — DuckDuckGo',
        'https://duckduckgo.com/?q=prism',
        const Duration(minutes: 6),
      ),
      h(
        'h3',
        'Flutter — Build apps for any screen',
        'https://flutter.dev',
        const Duration(hours: 2),
      ),
      h(
        'h4',
        'GitHub — prism-browser',
        'https://github.com/prism-browser',
        const Duration(hours: 3, minutes: 20),
      ),
      h(
        'h5',
        'Хабр — Как работает WebView2',
        'https://habr.com/ru/articles/',
        const Duration(days: 1, hours: 2),
      ),
      h(
        'h6',
        'Билеты в Калининград',
        'https://www.rzd.ru',
        const Duration(days: 1, hours: 5),
      ),
      h(
        'h7',
        'EFF — Surveillance Self-Defense',
        'https://ssd.eff.org',
        const Duration(days: 4),
      ),
    ];
  }

  static const downloads = [
    DownloadItem(
      id: 'd1',
      fileName: 'prism-wallpaper-4k.png',
      url: 'https://example.org/prism-wallpaper-4k.png',
      totalBytes: 8400000,
      receivedBytes: 5200000,
      state: DownloadState.running,
    ),
    DownloadItem(
      id: 'd2',
      fileName: 'flutter_windows_3.47.zip',
      url: 'https://storage.googleapis.com/flutter.zip',
      totalBytes: 1210000000,
      receivedBytes: 402000000,
      state: DownloadState.paused,
    ),
    DownloadItem(
      id: 'd3',
      fileName: 'Билеты_Калининград.pdf',
      url: 'https://www.rzd.ru/tickets.pdf',
      totalBytes: 284000,
      receivedBytes: 284000,
      state: DownloadState.completed,
    ),
    DownloadItem(
      id: 'd4',
      fileName: 'report-2026.xlsx',
      url: 'https://example.org/report.xlsx',
      totalBytes: 1500000,
      receivedBytes: 300000,
      state: DownloadState.failed,
    ),
  ];

  static const permissions = [
    SitePermission(
      host: 'meet.jit.si',
      kind: SitePermissionKind.camera,
      decision: PermissionDecision.allow,
    ),
    SitePermission(
      host: 'meet.jit.si',
      kind: SitePermissionKind.microphone,
      decision: PermissionDecision.allow,
    ),
    SitePermission(
      host: 'maps.yandex.ru',
      kind: SitePermissionKind.location,
      decision: PermissionDecision.ask,
    ),
    SitePermission(
      host: 'news-site.example',
      kind: SitePermissionKind.notifications,
      decision: PermissionDecision.block,
    ),
  ];

  /// Speed-dial on the start page.
  static const topSites = [
    ('Wikipedia', 'https://ru.wikipedia.org'),
    ('DuckDuckGo', 'https://duckduckgo.com'),
    ('GitHub', 'https://github.com'),
    ('Хабр', 'https://habr.com'),
    ('YouTube', 'https://youtube.com'),
    ('Flutter', 'https://flutter.dev'),
    ('Погода', 'https://yandex.ru/pogoda'),
    ('Карты', 'https://www.openstreetmap.org'),
  ];

  /// Blocked third-party requests on the current page: (host, isAd, count).
  static const blockedOnPage = [
    ('google-analytics.com', false, 4),
    ('doubleclick.net', true, 3),
    ('connect.facebook.net', false, 2),
    ('mc.yandex.ru', false, 1),
    ('adservice.google.com', true, 2),
  ];

  static const searchSuggestions = [
    'prism browser',
    'призма оптика',
    'prism dispersion of light',
  ];
}
