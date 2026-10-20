import 'package:flutter/foundation.dart';

/// A file the page wants to download (from the engine).
@immutable
class DownloadRequest {
  const DownloadRequest({
    required this.url,
    required this.incognito,
    this.contentDisposition,
    this.mimeType,
    this.contentLength = -1,
    this.suggestedFileName,
    this.userAgent,
  });

  final Uri url;
  final bool incognito;
  final String? contentDisposition;
  final String? mimeType;

  /// -1 when unknown.
  final int contentLength;
  final String? suggestedFileName;
  final String? userAgent;
}

/// File names for downloads: what the server suggests, made safe for the
/// file system. Names come from untrusted pages, so nothing in them may
/// pick a directory, a device or a misleading double extension.
abstract final class DownloadNames {
  static const _fallback = 'download';
  static const _maxLength = 150;

  /// Windows reserved device names (any extension).
  static final _reserved = RegExp(
    r'^(con|prn|aux|nul|com[0-9]|lpt[0-9])(\..*)?$',
    caseSensitive: false,
  );

  static const _mimeExtensions = {
    'application/pdf': 'pdf',
    'application/zip': 'zip',
    'application/json': 'json',
    'application/vnd.android.package-archive': 'apk',
    'application/x-msdownload': 'exe',
    'application/octet-stream': '',
    'image/png': 'png',
    'image/jpeg': 'jpg',
    'image/gif': 'gif',
    'image/webp': 'webp',
    'image/svg+xml': 'svg',
    'text/plain': 'txt',
    'text/csv': 'csv',
    'text/html': 'html',
    'audio/mpeg': 'mp3',
    'video/mp4': 'mp4',
  };

  /// Picks a name: Content-Disposition (RFC 6266 / 5987), then the
  /// engine's suggestion, then the last URL path segment; adds an extension
  /// from the MIME type when the name has none.
  static String guess({
    required Uri url,
    String? contentDisposition,
    String? suggested,
    String? mimeType,
  }) {
    final fromUrl = _nonEmpty(
      url.pathSegments.isEmpty ? null : _decode(url.pathSegments.last),
    );
    var name =
        _fromDisposition(contentDisposition) ??
        // A URL name with an extension beats the engine's guess (Android
        // turns "paper.pdf" served as octet-stream into "paper.bin").
        (fromUrl != null && fromUrl.contains('.') ? fromUrl : null) ??
        _nonEmpty(suggested) ??
        fromUrl ??
        _fallback;
    name = sanitize(name);
    if (!name.contains('.')) {
      final ext = _mimeExtensions[mimeType?.split(';').first.trim()];
      if (ext != null && ext.isNotEmpty) name = '$name.$ext';
    }
    return name;
  }

  /// Makes [raw] a single safe file name on Windows and Android.
  static String sanitize(String raw) {
    // Only the last path component: "../../x" and "C:\x" become "x".
    var s = raw.split(RegExp(r'[\\/]')).last;
    s = s
        // Control chars, Windows-forbidden chars and bidi overrides (used
        // to fake extensions: "photo\u202Egpj.exe").
        .replaceAll(
          RegExp(r'[\x00-\x1F\x7F<>:"|?*\u202A-\u202E\u2066-\u2069]'),
          '_',
        )
        .trim();
    // Leading dots would hide the file; trailing dots/spaces are dropped
    // by Windows and can change the extension.
    s = s.replaceFirst(RegExp(r'^\.+'), '').replaceFirst(RegExp(r'[. ]+$'), '');
    if (s.isEmpty) s = _fallback;
    if (_reserved.hasMatch(s)) s = '_$s';
    if (s.length > _maxLength) {
      final dot = s.lastIndexOf('.');
      final ext = dot > 0 && s.length - dot <= 10 ? s.substring(dot) : '';
      s = s.substring(0, _maxLength - ext.length) + ext;
    }
    return s;
  }

  /// "file.pdf", then "file (1).pdf", "file (2).pdf"... — the first name
  /// for which [exists] is false.
  static String unique(String name, bool Function(String) exists) {
    if (!exists(name)) return name;
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    for (var i = 1; i < 10000; i++) {
      final candidate = '$base ($i)$ext';
      if (!exists(candidate)) return candidate;
    }
    return '$base (${DateTime.now().millisecondsSinceEpoch})$ext';
  }

  static String? _fromDisposition(String? header) {
    if (header == null || header.isEmpty) return null;
    // filename*=UTF-8''na%C3%AFve.txt wins over filename=.
    final star = RegExp(
      r"""filename\*\s*=\s*([\w-]+)'[^']*'([^;]+)""",
      caseSensitive: false,
    ).firstMatch(header);
    if (star != null) {
      final v = _decode(star.group(2)!.trim().replaceAll('"', ''));
      if (v.trim().isNotEmpty) return v;
    }
    final plain = RegExp(
      r'''filename\s*=\s*("((?:[^"\\]|\\.)*)"|[^;]+)''',
      caseSensitive: false,
    ).firstMatch(header);
    if (plain == null) return null;
    final v = (plain.group(2) ?? plain.group(1)!).replaceAll(r'\"', '"').trim();
    return v.isEmpty ? null : v;
  }

  static String _decode(String s) {
    try {
      return Uri.decodeComponent(s);
    } on ArgumentError {
      return s;
    }
  }

  static String? _nonEmpty(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();
}
