import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/browser/download_names.dart';
import '../../domain/browser/downloads.dart';
import '../../domain/browser/models.dart';
import '../../domain/browser/repositories.dart';
import 'browser_providers.dart';

/// All downloads: started by pages (engine requests), written by Prism
/// to `<name>.part` and renamed when complete. Pause cancels the transfer
/// and keeps the part file; resume asks for the rest with an HTTP Range
/// request and starts over if the server does not support it.
class DownloadsController extends Notifier<List<DownloadItem>> {
  final _live = <String, DownloadResponse>{};
  final _stopping = <String, bool>{}; // id -> remove (true) / pause (false)
  final _headers = <String, Map<String, String>>{};
  int _seq = 0;

  DownloadsRepository get _repo => ref.read(downloadsRepositoryProvider);
  DownloadTransport get _net => ref.read(downloadTransportProvider);
  PlatformFiles get _files => ref.read(platformFilesProvider);

  @override
  List<DownloadItem> build() {
    final sub = ref
        .watch(engineProvider)
        .downloadRequests
        .listen((r) => start(r).ignore());
    ref.onDispose(() {
      sub.cancel();
      for (final r in _live.values) {
        r.cancel();
      }
    });
    _restore().ignore();
    return const [];
  }

  Future<void> _restore() async {
    final saved = await _repo.all();
    // Transfers cut short by quitting the app continue as "paused" (demo
    // fixtures keep their state for the showcase).
    final demo = ref.read(demoDataProvider);
    final fixed = [
      for (final d in saved)
        d.state == DownloadState.running && !demo
            ? d.copyWith(state: DownloadState.paused)
            : d,
    ];
    if (!ref.mounted) return;
    final known = {for (final d in state) d.id};
    state = [...state, ...fixed.where((d) => !known.contains(d.id))];
  }

  void _put(DownloadItem d, {bool persist = true}) {
    final i = state.indexWhere((e) => e.id == d.id);
    state = i < 0 ? [d, ...state] : ([...state]..[i] = d);
    if (persist) _repo.upsert(d).ignore();
  }

  DownloadItem? _find(String id) {
    for (final d in state) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// A page asked to download a file.
  Future<DownloadItem> start(DownloadRequest r) async {
    final dir = await _files.downloadsDirectory();
    String pathOf(String n) => '$dir${Platform.pathSeparator}$n';
    final name = DownloadNames.unique(
      DownloadNames.guess(
        url: r.url,
        contentDisposition: r.contentDisposition,
        suggested: r.suggestedFileName,
        mimeType: r.mimeType,
      ),
      (n) =>
          File(pathOf(n)).existsSync() ||
          File('${pathOf(n)}.part').existsSync() ||
          state.any((d) => d.filePath == pathOf(n)),
    );
    final item = DownloadItem(
      id: 'dl-${ref.read(clockProvider)().microsecondsSinceEpoch}-${_seq++}',
      fileName: name,
      url: r.url.toString(),
      totalBytes: r.contentLength > 0 ? r.contentLength : -1,
      receivedBytes: 0,
      state: DownloadState.running,
      filePath: pathOf(name),
      mimeType: r.mimeType,
      createdAt: ref.read(clockProvider)(),
      incognito: r.incognito,
    );
    _put(item);
    final cookie = await ref
        .read(engineProvider)
        .cookieHeader(r.url, incognito: r.incognito);
    _headers[item.id] = {
      if (r.userAgent != null) HttpHeaders.userAgentHeader: r.userAgent!,
      HttpHeaders.cookieHeader: ?cookie,
    };
    if (r.url.scheme == 'data') {
      await _saveDataUri(item, r.url);
    } else {
      await _run(item, from: 0);
    }
    return _find(item.id) ?? item;
  }

  Future<void> _saveDataUri(DownloadItem item, Uri url) async {
    try {
      final bytes = UriData.fromUri(url).contentAsBytes();
      await File(item.filePath).writeAsBytes(bytes, flush: true);
      await _finish(
        item.copyWith(totalBytes: bytes.length, receivedBytes: bytes.length),
      );
    } on Object {
      _put(item.copyWith(state: DownloadState.failed));
    }
  }

  Future<void> _run(DownloadItem item, {required int from}) async {
    final url = Uri.parse(item.url);
    if (url.scheme != 'http' && url.scheme != 'https') {
      // blob: and other page-only URLs cannot be fetched outside the page.
      _put(item.copyWith(state: DownloadState.failed));
      return;
    }
    final part = File('${item.filePath}.part');
    var current = item.copyWith(state: DownloadState.running);
    _put(current);
    IOSink? sink;
    try {
      final resp = await _net.open(
        url,
        from: from,
        headers: _headers[item.id] ?? const {},
      );
      _live[item.id] = resp;
      if (!resp.ok) {
        resp.cancel();
        throw HttpException('HTTP ${resp.statusCode}');
      }
      // Server ignored the Range header: start over.
      final offset = from > 0 && resp.partial ? from : 0;
      final total = resp.contentLength >= 0
          ? offset + resp.contentLength
          : current.totalBytes;
      sink = part.openWrite(
        mode: offset > 0 ? FileMode.append : FileMode.write,
      );
      var received = offset;
      final clock = Stopwatch()..start();
      var shown = -1000, saved = 0;
      await for (final chunk in resp.body) {
        sink.add(chunk);
        received += chunk.length;
        final ms = clock.elapsedMilliseconds;
        if (ms - shown >= 200) {
          shown = ms;
          final persist = ms - saved >= 2000;
          if (persist) saved = ms;
          current = current.copyWith(
            receivedBytes: received,
            totalBytes: total,
          );
          _put(current, persist: persist);
        }
      }
      await sink.close();
      sink = null;
      current = current.copyWith(receivedBytes: received, totalBytes: total);
      if (_stopping.containsKey(item.id)) {
        _stopped(current);
        return;
      }
      if (total > 0 && received < total) {
        throw const HttpException('Connection closed early');
      }
      await part.rename(item.filePath);
      await _finish(current.copyWith(totalBytes: received));
    } on Object {
      await sink?.close();
      if (_stopping.containsKey(item.id)) {
        _stopped(current);
      } else {
        _put(
          current.copyWith(
            state: DownloadState.failed,
            receivedBytes: part.existsSync() ? part.lengthSync() : 0,
          ),
        );
      }
    } finally {
      _live.remove(item.id);
    }
  }

  void _stopped(DownloadItem d) {
    final remove = _stopping.remove(d.id) ?? false;
    if (remove) return;
    _put(d.copyWith(state: DownloadState.paused));
  }

  Future<void> _finish(DownloadItem d) async {
    var done = d.copyWith(state: DownloadState.completed);
    final uri = await _files.publish(done);
    if (uri != null) done = done.copyWith(contentUri: uri);
    _put(done);
  }

  void pause(String id) {
    final resp = _live[id];
    if (resp == null) return;
    _stopping[id] = false;
    resp.cancel();
  }

  /// Resume a paused download or retry a failed one.
  Future<void> resume(String id) async {
    final d = _find(id);
    if (d == null || _live.containsKey(id)) return;
    if (d.state != DownloadState.paused && d.state != DownloadState.failed) {
      return;
    }
    final part = File('${d.filePath}.part');
    final from = part.existsSync() ? part.lengthSync() : 0;
    await _run(d, from: from);
  }

  /// Play/pause button.
  void toggle(String id) {
    final d = _find(id);
    if (d == null) return;
    if (d.state == DownloadState.running) {
      pause(id);
    } else {
      resume(id).ignore();
    }
  }

  /// Removes the entry; an unfinished part file is deleted, a finished
  /// file stays where it is.
  Future<void> remove(String id) async {
    final d = _find(id);
    if (d == null) return;
    final resp = _live[id];
    if (resp != null) {
      _stopping[id] = true;
      resp.cancel();
    }
    state = state.where((e) => e.id != id).toList();
    await _repo.delete(id);
    if (d.state != DownloadState.completed) {
      final part = File('${d.filePath}.part');
      if (part.existsSync()) await part.delete();
    }
  }

  Future<bool> open(String id) async {
    final d = _find(id);
    if (d == null || d.state != DownloadState.completed) return false;
    return _files.open(d);
  }

  /// Incognito downloads leave the list when incognito is closed.
  void forgetIncognito() => state = state.where((d) => !d.incognito).toList();
}
