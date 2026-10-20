import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/domain/browser/download_names.dart';

void main() {
  Uri u(String s) => Uri.parse(s);

  group('guess', () {
    test('Content-Disposition first, RFC 5987 filename* wins', () {
      expect(
        DownloadNames.guess(
          url: u('https://a.example/get?id=1'),
          contentDisposition: 'attachment; filename="report.pdf"',
        ),
        'report.pdf',
      );
      expect(
        DownloadNames.guess(
          url: u('https://a.example/x'),
          contentDisposition: "attachment; filename=\"fallback.txt\"; filename*=UTF-8''%D0%BE%D1%82%D1%87%D1%91%D1%82.txt",
        ),
        'отчёт.txt',
      );
      expect(
        DownloadNames.guess(
          url: u('https://a.example/x'),
          contentDisposition: 'attachment; filename=plain.zip',
        ),
        'plain.zip',
      );
    });

    test('a URL name with an extension beats the engine guess', () {
      expect(
        DownloadNames.guess(
          url: u('https://raw.example/pdfs/tracemonkey.pdf'),
          suggested: 'tracemonkey.bin',
          mimeType: 'application/octet-stream',
        ),
        'tracemonkey.pdf',
      );
      expect(
        DownloadNames.guess(
          url: u('https://a.example/get'),
          suggested: 'invoice.pdf',
        ),
        'invoice.pdf',
      );
    });

    test('then the URL path, decoded', () {
      expect(
        DownloadNames.guess(url: u('https://a.example/files/My%20Doc.pdf?x=1')),
        'My Doc.pdf',
      );
    });

    test('adds an extension from the MIME type', () {
      expect(
        DownloadNames.guess(
          url: u('https://a.example/'),
          mimeType: 'application/pdf',
        ),
        'download.pdf',
      );
      expect(
        DownloadNames.guess(
          url: u('https://a.example/photo'),
          mimeType: 'image/jpeg; charset=binary',
        ),
        'photo.jpg',
      );
    });
  });

  group('sanitize (untrusted names)', () {
    test('no directories, drives or traversal', () {
      expect(DownloadNames.sanitize('../../etc/passwd'), 'passwd');
      expect(
        DownloadNames.sanitize(r'C:\Windows\system32\evil.dll'),
        'evil.dll',
      );
      expect(DownloadNames.sanitize('..'), 'download');
    });

    test('forbidden characters, reserved names, hidden files', () {
      expect(
        DownloadNames.sanitize('a<b>c:d"e|f?g*.txt'),
        'a_b_c_d_e_f_g_.txt',
      );
      expect(DownloadNames.sanitize('CON.txt'), '_CON.txt');
      expect(DownloadNames.sanitize('nul'), '_nul');
      expect(DownloadNames.sanitize('.bashrc'), 'bashrc');
      expect(DownloadNames.sanitize('setup.exe. . '), 'setup.exe');
    });

    test('bidi override cannot fake the extension', () {
      final s = DownloadNames.sanitize('photo\u202Egpj.exe');
      expect(s.endsWith('.exe'), isTrue);
      expect(s.contains('\u202E'), isFalse);
    });

    test('long names keep their extension', () {
      final s = DownloadNames.sanitize('${'a' * 300}.pdf');
      expect(s.length, 150);
      expect(s.endsWith('.pdf'), isTrue);
    });
  });

  test('unique adds a counter before the extension', () {
    final taken = {'a.pdf', 'a (1).pdf'};
    expect(DownloadNames.unique('a.pdf', taken.contains), 'a (2).pdf');
    expect(DownloadNames.unique('b.pdf', taken.contains), 'b.pdf');
    expect(DownloadNames.unique('noext', {'noext'}.contains), 'noext (1)');
  });
}
