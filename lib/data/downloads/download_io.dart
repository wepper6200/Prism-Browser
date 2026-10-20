import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/browser/downloads.dart';
import '../../domain/browser/models.dart';

/// Downloads over dart:io. Only http(s); redirects are followed by
/// HttpClient (http(s) only, at most 10).
class HttpDownloadTransport implements DownloadTransport {
  HttpDownloadTransport({HttpClient? client})
    : _client =
          client ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 20));

  final HttpClient _client;

  @override
  Future<DownloadResponse> open(
    Uri url, {
    int from = 0,
    Map<String, String> headers = const {},
  }) async {
    if (url.scheme != 'https' && url.scheme != 'http') {
      throw ArgumentError('Unsupported scheme: ${url.scheme}');
    }
    final request = await _client.getUrl(url);
    request.followRedirects = true;
    request.maxRedirects = 10;
    headers.forEach(request.headers.set);
    if (from > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$from-');
    final response = await request.close();
    return DownloadResponse(
      statusCode: response.statusCode,
      contentLength: response.contentLength,
      mimeType: response.headers.contentType?.mimeType,
      body: response,
      cancel: () {
        try {
          response.detachSocket().then((s) => s.destroy()).ignore();
        } on Object {
          request.abort();
        }
      },
    );
  }
}

/// Where downloads go and how they are opened, per platform.
class AppPlatformFiles implements PlatformFiles {
  static const _channel = MethodChannel('app.prism.browser/files');

  @override
  Future<String> downloadsDirectory() async {
    // Windows: the user's Downloads folder. Android: the app's own
    // Downloads folder (no storage permission needed); finished files are
    // then copied to the public Downloads folder by [publish].
    final dir =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return dir.path;
  }

  @override
  Future<String?> publish(DownloadItem item) async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      return await _channel.invokeMethod<String>('publishDownload', {
        'path': item.filePath,
        'name': item.fileName,
        'mime': item.mimeType,
      });
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> open(DownloadItem item) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      if (!File(item.filePath).existsSync()) return false;
      // explorer.exe opens a file with its default app. The path is one
      // argument (no shell), so names cannot inject commands.
      await Process.start('explorer.exe', [item.filePath]);
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        return await _channel.invokeMethod<bool>('open', {
              'uri': item.contentUri,
              'path': item.filePath,
              'mime': item.mimeType,
            }) ??
            false;
      } on PlatformException {
        return false;
      }
    }
    return false;
  }
}
