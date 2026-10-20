import 'punycode.dart';

/// Turns omnibox input into a URL to load: an address when it looks like
/// one, otherwise a search with the chosen engine. Pure Dart, unit-tested.
abstract final class UrlResolver {
  static final _ipv4 = RegExp(r'^(\d{1,3})(\.\d{1,3}){3}(:\d{1,5})?(/.*)?$');
  static final _hostLike = RegExp(
    r'^([a-z0-9¡-￿]([a-z0-9¡-￿-]{0,61}[a-z0-9¡-￿])?\.)+'
    r'([a-z¡-￿]{2,63}|xn--[a-z0-9-]{1,59})(:\d{1,5})?([/?#].*)?$',
    caseSensitive: false,
  );
  static final _localhost = RegExp(
    r'^localhost(:\d{1,5})?([/?#].*)?$',
    caseSensitive: false,
  );

  /// Schemes the omnibox may open directly. `javascript:`, `data:` and
  /// `file:` are refused (bookmarklet/phishing vectors from pasted text).
  static const allowedSchemes = {'http', 'https', 'about'};

  /// [searchTemplate] contains `%s` for the encoded query.
  static Uri? resolve(String input, {required String searchTemplate}) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final schemeMatch = RegExp(
      r'^([a-z][a-z0-9+.-]*):',
      caseSensitive: false,
    ).firstMatch(text);
    if (schemeMatch != null && !_looksLikeHostPort(text)) {
      final scheme = schemeMatch.group(1)!.toLowerCase();
      if (!allowedSchemes.contains(scheme)) {
        return _search(text, searchTemplate);
      }
      final uri = Uri.tryParse(text);
      if (uri != null && (scheme == 'about' || uri.host.isNotEmpty)) {
        return uri;
      }
      return _search(text, searchTemplate);
    }

    if (text.contains(RegExp(r'\s'))) return _search(text, searchTemplate);

    if (_localhost.hasMatch(text) || _isIpv4(text) || text.startsWith('[')) {
      return Uri.tryParse('http://$text') ?? _search(text, searchTemplate);
    }
    if (_hostLike.hasMatch(text)) {
      return _withAsciiHost('https://$text') ?? _search(text, searchTemplate);
    }
    return _search(text, searchTemplate);
  }

  /// Parses [url] with the host converted to punycode (IDN support).
  static Uri? _withAsciiHost(String url) {
    final m = RegExp(
      r'^([a-z]+://)([^/?#:]+)(.*)$',
      caseSensitive: false,
    ).firstMatch(url);
    if (m == null) return Uri.tryParse(url);
    return Uri.tryParse('${m[1]}${Punycode.toAscii(m[2]!)}${m[3]}');
  }

  /// True when [input] would open an address rather than run a search
  /// (the omnibox then offers "Go to address" first).
  static bool looksLikeAddress(String input) =>
      resolve(input, searchTemplate: 'prism-search:%s')?.scheme !=
          'prism-search' &&
      input.trim().isNotEmpty;

  /// "example.com:8080" parses as scheme "example.com" — treat as host.
  static bool _looksLikeHostPort(String text) =>
      RegExp(r'^[^/:\s]+:\d{1,5}([/?#].*)?$').hasMatch(text);

  static bool _isIpv4(String text) {
    final m = _ipv4.firstMatch(text);
    if (m == null) return false;
    final host = text.split(RegExp(r'[:/]')).first;
    return host.split('.').every((p) => int.parse(p) <= 255);
  }

  static Uri _search(String query, String template) =>
      Uri.parse(template.replaceAll('%s', Uri.encodeQueryComponent(query)));

  /// What the address bar shows when not editing: host on phones, the
  /// full URL on desktop (both without trailing slash noise).
  static String display(Uri? url, {required bool full}) {
    if (url == null) return '';
    final host = Punycode.toDisplay(url.host);
    if (!full) {
      return host.startsWith('www.') ? host.substring(4) : host;
    }
    var s = Uri.decodeFull(url.toString()).replaceFirst(url.host, host);
    if (s.endsWith('/') && url.path == '/') s = s.substring(0, s.length - 1);
    return s;
  }
}
