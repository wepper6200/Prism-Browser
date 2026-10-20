import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/domain/engine/punycode.dart';
import 'package:prism_browser/domain/engine/url_resolver.dart';

void main() {
  const ddg = 'https://duckduckgo.com/?q=%s';
  Uri? r(String s) => UrlResolver.resolve(s, searchTemplate: ddg);
  String search(String q) =>
      'https://duckduckgo.com/?q=${Uri.encodeQueryComponent(q)}';

  group('addresses', () {
    test('bare domains get https', () {
      expect(r('example.com').toString(), 'https://example.com');
      expect(
        r('  ru.wikipedia.org/wiki/Призма ').toString(),
        'https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D0%B8%D0%B7%D0%BC%D0%B0',
      );
      expect(
        r('sub.domain.co.uk?x=1').toString(),
        'https://sub.domain.co.uk?x=1',
      );
    });

    test('explicit schemes are kept', () {
      expect(r('http://neverssl.com').toString(), 'http://neverssl.com');
      expect(r('HTTPS://Example.com/a').toString(), 'https://example.com/a');
      expect(r('about:blank').toString(), 'about:blank');
    });

    test('host:port is an address, not a scheme', () {
      expect(r('example.com:8080').toString(), 'https://example.com:8080');
      expect(r('localhost:3000/api').toString(), 'http://localhost:3000/api');
    });

    test('local and IP addresses default to http', () {
      expect(r('localhost').toString(), 'http://localhost');
      expect(r('192.168.1.1').toString(), 'http://192.168.1.1');
      expect(r('10.0.2.2:8080/x').toString(), 'http://10.0.2.2:8080/x');
      expect(r('[::1]:8080').toString(), 'http://[::1]:8080');
    });

    test('IDN hosts are converted to punycode', () {
      expect(r('пример.рф')!.host, 'xn--e1afmkfd.xn--p1ai');
      expect(r('Пример.РФ/путь')!.host, 'xn--e1afmkfd.xn--p1ai');
      expect(r('example.xn--p1ai')!.scheme, 'https');
      expect(r('münchen.de')!.host, 'xn--mnchen-3ya.de');
    });
  });

  group('searches', () {
    test('words and sentences', () {
      expect(r('prism').toString(), search('prism'));
      expect(r('призма оптика').toString(), search('призма оптика'));
      expect(r('flutter.dev docs').toString(), search('flutter.dev docs'));
    });

    test('invalid IPs and numbers are searches', () {
      expect(r('999.1.1.1').toString(), search('999.1.1.1'));
      expect(r('3.14').toString(), search('3.14'));
    });

    test('dangerous schemes are never opened', () {
      expect(r('javascript:alert(1)')!.host, 'duckduckgo.com');
      expect(r('data:text/html,<b>x</b>')!.host, 'duckduckgo.com');
      expect(r('file:///etc/passwd')!.host, 'duckduckgo.com');
    });

    test('special characters are encoded', () {
      expect(r('c++ & dart?')!.queryParameters['q'], 'c++ & dart?');
    });

    test('empty input resolves to nothing', () {
      expect(r('   '), isNull);
    });

    test('looksLikeAddress drives the omnibox first row', () {
      expect(UrlResolver.looksLikeAddress('example.com'), isTrue);
      expect(
        UrlResolver.looksLikeAddress('https://ru.wikipedia.org/wiki/x'),
        isTrue,
      );
      expect(UrlResolver.looksLikeAddress('localhost:8080'), isTrue);
      expect(UrlResolver.looksLikeAddress('призма оптика'), isFalse);
      expect(UrlResolver.looksLikeAddress('javascript:alert(1)'), isFalse);
      expect(UrlResolver.looksLikeAddress(''), isFalse);
    });
  });

  test('display: host on phones, full URL on desktop', () {
    final u = Uri.parse('https://www.example.com/');
    expect(UrlResolver.display(u, full: false), 'example.com');
    expect(UrlResolver.display(u, full: true), 'https://www.example.com');
    expect(
      UrlResolver.display(
        Uri.parse(
          'https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D0%B8%D0%B7%D0%BC%D0%B0',
        ),
        full: true,
      ),
      'https://ru.wikipedia.org/wiki/Призма',
    );
    expect(UrlResolver.display(null, full: true), '');
  });

  test('display decodes single-script IDN, keeps mixed-script spoofs', () {
    expect(
      UrlResolver.display(
        Uri.parse('https://xn--e1afmkfd.xn--p1ai/'),
        full: false,
      ),
      'пример.рф',
    );
    // "аpple.com" with Cyrillic "а": must stay visibly punycode.
    final spoof = Punycode.toAscii('аpple.com');
    expect(spoof, startsWith('xn--'));
    expect(
      UrlResolver.display(Uri.parse('https://$spoof'), full: false),
      spoof,
    );
  });

  test('punycode round-trips RFC 3492 samples', () {
    for (final s in ['пример', 'münchen', 'bücher', '例え', 'ü']) {
      expect(Punycode.decodeLabel(Punycode.encodeLabel(s)), s);
    }
    expect(Punycode.encodeLabel('bücher'), 'bcher-kva');
  });
}
