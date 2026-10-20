import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/domain/browser/models.dart';
import 'package:prism_browser/domain/engine/punycode.dart';

void main() {
  CustomTemplateResult v(String s) => CustomSearchTemplate.validate(s);

  test('valid templates are normalized', () {
    expect(
      v('https://searx.example.org/search?q=%s').template,
      'https://searx.example.org/search?q=%s',
    );
    expect(
      v('  search.example.org/?q=%s ').template,
      'https://search.example.org/?q=%s',
    );
    expect(
      v('HTTPS://Kagi.com/search?q=%s').template,
      'https://kagi.com/search?q=%s',
    );
    expect(
      v('https://example.com/search?q={searchTerms}&lang=ru').template,
      'https://example.com/search?q=%s&lang=ru',
    );
    final idn = v('поиск.рф/?q=%s').template!;
    final host = Uri.parse(idn.replaceFirst('%s', 'q')).host;
    expect(host, startsWith('xn--'));
    expect(Punycode.toDisplay(host), 'поиск.рф');
    expect(
      v('http://localhost:8888/search?q=%s').template,
      'http://localhost:8888/search?q=%s',
    );
  });

  test('plain http is allowed but flagged insecure', () {
    final r = v('http://192.168.1.10/search?q=%s');
    expect(r.isValid, isTrue);
    expect(r.insecure, isTrue);
    expect(v('https://a.org/?q=%s').insecure, isFalse);
  });

  test('errors', () {
    expect(v('   ').error, CustomTemplateError.empty);
    expect(
      v('https://example.com/search?q=').error,
      CustomTemplateError.missingPlaceholder,
    );
    expect(
      v('https://example.com/?q=%s&x=%s').error,
      CustomTemplateError.tooManyPlaceholders,
    );
    expect(v('javascript:alert(%s)').error, CustomTemplateError.invalidUrl);
    expect(v('ftp://example.com/?q=%s').error, CustomTemplateError.invalidUrl);
    expect(v('notadomain/?q=%s').error, CustomTemplateError.invalidUrl);
  });

  test('name suggestion from host', () {
    expect(
      CustomSearchTemplate.suggestName('https://www.example.org/?q=%s'),
      'example.org',
    );
  });

  test('custom engine builds search URLs', () {
    final e = SearchEngine.custom(
      name: 'SearX',
      template: 'https://searx.example.org/search?q=%s',
    );
    expect(e.id, SearchEngineId.custom);
    expect(e.privacyFriendly, isFalse);
  });
}
