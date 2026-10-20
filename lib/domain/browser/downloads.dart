import 'package:flutter/foundation.dart';

import 'models.dart';

/// One HTTP response body for a download, possibly from a byte offset.
@immutable
class DownloadResponse {
  const DownloadResponse({
    required this.statusCode,
    required this.body,
    required this.cancel,
    this.contentLength = -1,
    this.mimeType,
  });

  final int statusCode;

  /// Bytes of THIS response (-1 unknown). For 206 it is the remainder.
  final int contentLength;
  final String? mimeType;
  final Stream<List<int>> body;

  /// Aborts the transfer (pause / cancel).
  final void Function() cancel;

  bool get ok => statusCode >= 200 && statusCode < 300;

  /// The server honoured a Range request.
  bool get partial => statusCode == 206;
}

/// Network side of downloads (dart:io in the app, a fake in tests).
abstract interface class DownloadTransport {
  /// GET [url]; when [from] > 0 asks for the bytes from that offset.
  Future<DownloadResponse> open(
    Uri url, {
    int from = 0,
    Map<String, String> headers = const {},
  });
}

/// Platform file actions for finished downloads.
abstract interface class PlatformFiles {
  /// Directory new downloads are written to.
  Future<String> downloadsDirectory();

  /// Android 10+: copies the file into the public Downloads folder and
  /// returns its content:// URI (null where not needed or not possible).
  Future<String?> publish(DownloadItem item);

  /// Opens the file with the system's default app. False if it failed.
  Future<bool> open(DownloadItem item);
}
