import 'dart:async';
import 'dart:io';

import 'package:prism_browser/data/search/suggest_client.dart';
import 'package:prism_browser/domain/browser/downloads.dart';
import 'package:prism_browser/domain/browser/models.dart';

/// Offline download server: serves [files] by URL, honours Range when
/// [ranges] is true, and can stall to let tests pause mid-transfer.
class FakeTransport implements DownloadTransport {
  FakeTransport({this.files = const {}, this.ranges = true});

  final Map<String, List<int>> files;
  final bool ranges;
  final requests = <(Uri, int)>[];

  /// When set, bodies stop after this many bytes until [release].
  int? stallAfter;
  final _gates = <Completer<void>>[];

  void release() {
    stallAfter = null;
    for (final g in _gates) {
      if (!g.isCompleted) g.complete();
    }
    _gates.clear();
  }

  @override
  Future<DownloadResponse> open(
    Uri url, {
    int from = 0,
    Map<String, String> headers = const {},
  }) async {
    requests.add((url, from));
    final data = files[url.toString()];
    if (data == null) {
      return DownloadResponse(
        statusCode: 404,
        body: const Stream.empty(),
        cancel: () {},
      );
    }
    final partial = ranges && from > 0;
    final bytes = partial ? data.sublist(from) : data;
    final controller = StreamController<List<int>>();
    var cancelled = false;
    Future<void> pump() async {
      var sent = 0;
      const chunk = 4;
      while (sent < bytes.length && !cancelled) {
        final limit = stallAfter;
        if (limit != null && sent >= limit) {
          final gate = Completer<void>();
          _gates.add(gate);
          await gate.future;
          continue;
        }
        final end = (sent + chunk).clamp(0, bytes.length);
        controller.add(bytes.sublist(sent, end));
        sent = end;
        await Future<void>.delayed(Duration.zero);
      }
      if (cancelled) {
        controller.addError(const SocketException('cancelled'));
      }
      await controller.close();
    }

    pump().ignore();
    return DownloadResponse(
      statusCode: partial ? 206 : 200,
      contentLength: bytes.length,
      body: controller.stream,
      cancel: () {
        cancelled = true;
        release();
      },
    );
  }
}

class FakePlatformFiles implements PlatformFiles {
  FakePlatformFiles(this.dir);

  final String dir;
  final opened = <String>[];

  @override
  Future<String> downloadsDirectory() async => dir;

  @override
  Future<String?> publish(DownloadItem item) async => null;

  @override
  Future<bool> open(DownloadItem item) async {
    opened.add(item.filePath);
    return true;
  }
}

class FakeSuggestClient implements SuggestClient {
  final calls = <(SearchEngineId, String)>[];

  @override
  Future<List<String>> suggest(SearchEngineId engine, String query) async {
    calls.add((engine, query));
    return ['$query browser', '$query оптика'];
  }
}
