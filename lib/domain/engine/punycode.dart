/// Punycode (RFC 3492) + IDNA host helpers. Dart's [Uri] percent-encodes
/// non-ASCII hosts, which engines reject, so hosts are converted to their
/// ASCII "xn--" form before loading.
abstract final class Punycode {
  static const _base = 36, _tMin = 1, _tMax = 26, _skew = 38, _damp = 700;
  static const _initialBias = 72, _initialN = 128;

  static int _adapt(int delta, int numPoints, bool first) {
    var d = first ? delta ~/ _damp : delta ~/ 2;
    d += d ~/ numPoints;
    var k = 0;
    while (d > ((_base - _tMin) * _tMax) ~/ 2) {
      d ~/= _base - _tMin;
      k += _base;
    }
    return k + (_base - _tMin + 1) * d ~/ (d + _skew);
  }

  static String _digit(int d) => String.fromCharCode(d < 26 ? d + 97 : d + 22);

  static int _value(int c) {
    if (c >= 48 && c <= 57) return c - 22; // 0-9 -> 26..35
    if (c >= 65 && c <= 90) return c - 65; // A-Z
    if (c >= 97 && c <= 122) return c - 97; // a-z
    throw const FormatException('bad punycode digit');
  }

  static String encodeLabel(String label) {
    final input = label.runes.toList();
    final out = StringBuffer();
    for (final c in input) {
      if (c < 0x80) out.writeCharCode(c);
    }
    final basic = out.length;
    var h = basic;
    if (basic > 0) out.write('-');
    var n = _initialN, delta = 0, bias = _initialBias;
    while (h < input.length) {
      final m = input.where((c) => c >= n).reduce((a, b) => a < b ? a : b);
      delta += (m - n) * (h + 1);
      n = m;
      for (final c in input) {
        if (c < n) delta++;
        if (c == n) {
          var q = delta;
          for (var k = _base; ; k += _base) {
            final t = k <= bias
                ? _tMin
                : (k >= bias + _tMax ? _tMax : k - bias);
            if (q < t) break;
            out.write(_digit(t + (q - t) % (_base - t)));
            q = (q - t) ~/ (_base - t);
          }
          out.write(_digit(q));
          bias = _adapt(delta, h + 1, h == basic);
          delta = 0;
          h++;
        }
      }
      delta++;
      n++;
    }
    return out.toString();
  }

  static String decodeLabel(String encoded) {
    final out = <int>[];
    final dash = encoded.lastIndexOf('-');
    if (dash > 0) out.addAll(encoded.substring(0, dash).codeUnits);
    var n = _initialN, i = 0, bias = _initialBias;
    var pos = dash > 0 ? dash + 1 : 0;
    while (pos < encoded.length) {
      final oldi = i;
      var w = 1;
      for (var k = _base; ; k += _base) {
        final digit = _value(encoded.codeUnitAt(pos++));
        i += digit * w;
        final t = k <= bias ? _tMin : (k >= bias + _tMax ? _tMax : k - bias);
        if (digit < t) break;
        w *= _base - t;
      }
      bias = _adapt(i - oldi, out.length + 1, oldi == 0);
      n += i ~/ (out.length + 1);
      i %= out.length + 1;
      out.insert(i, n);
      i++;
    }
    return String.fromCharCodes(out);
  }

  /// "пример.рф" -> "xn--e1afmkfd.xn--p1ai"; ASCII hosts unchanged.
  static String toAscii(String host) => host
      .toLowerCase()
      .split('.')
      .map((l) => l.runes.any((c) => c >= 0x80) ? 'xn--${encodeLabel(l)}' : l)
      .join('.');

  /// Decodes xn-- labels for display, but only when the whole host uses a
  /// single script (Latin or Cyrillic or Greek). Mixed-script hosts stay in
  /// punycode so homograph spoofs like "аpple.com" (Cyrillic а) are visible.
  static String toDisplay(String host) {
    final decoded = host
        .split('.')
        .map((l) {
          if (!l.startsWith('xn--')) return l;
          try {
            return decodeLabel(l.substring(4));
          } on FormatException {
            return l;
          }
        })
        .join('.');
    if (decoded == host) return host;
    final scripts = <String>{};
    for (final c in decoded.runes) {
      if ((c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A)) {
        scripts.add('latin');
      }
      if (c >= 0x0400 && c <= 0x04FF) scripts.add('cyrillic');
      if (c >= 0x0370 && c <= 0x03FF) scripts.add('greek');
    }
    return scripts.length <= 1 ? decoded : host;
  }
}
