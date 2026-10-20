import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import 'library_format.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  static IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'png' || 'jpg' || 'jpeg' || 'webp' => PrismIcons.fileImage,
      'zip' || '7z' || 'rar' => PrismIcons.fileZip,
      'pdf' => PrismIcons.pdf,
      'xlsx' || 'csv' => PrismIcons.fileSheet,
      'txt' || 'md' => PrismIcons.fileText,
      _ => PrismIcons.file,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final items = ref.watch(downloadsProvider);
    final c = ref.read(downloadsProvider.notifier);
    return PrismPage(
      title: l.downloadsTitle,
      children: [
        if (items.isEmpty)
          PrismEmptyState(
            icon: PrismIcons.downloads,
            title: l.emptyDownloadsTitle,
            body: l.emptyDownloadsBody,
          )
        else
          PrismSection(
            children: [
              for (final d in items)
                PrismTile(
                  icon: _fileIcon(d.fileName),
                  tone: switch (d.state) {
                    DownloadState.failed => PrismBadgeTone.danger,
                    DownloadState.completed => PrismBadgeTone.secure,
                    _ => PrismBadgeTone.accent,
                  },
                  title: d.fileName,
                  subtitle: switch (d.state) {
                    DownloadState.completed =>
                      '${l.downloadDone} · ${formatBytes(l, d.totalBytes)}',
                    DownloadState.failed => l.downloadFailed,
                    DownloadState.paused =>
                      '${l.downloadPaused} · ${l.downloadProgress(formatBytes(l, d.receivedBytes), formatBytes(l, d.totalBytes))}',
                    DownloadState.running => l.downloadProgress(
                      formatBytes(l, d.receivedBytes),
                      formatBytes(l, d.totalBytes),
                    ),
                  },
                  trailing: switch (d.state) {
                    DownloadState.running || DownloadState.paused => SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: d.progress,
                            strokeWidth: 3,
                            backgroundColor: t.outline,
                          ),
                          PrismIconButton(
                            icon: d.state == DownloadState.running
                                ? PrismIcons.pause
                                : PrismIcons.play,
                            tooltip: d.state == DownloadState.running
                                ? l.actionPause
                                : l.actionResume,
                            onPressed: () => c.toggle(d.id),
                          ),
                        ],
                      ),
                    ),
                    DownloadState.completed => PrismIconButton(
                      icon: PrismIcons.external,
                      tooltip: l.actionOpenFile,
                      onPressed: () {},
                    ),
                    DownloadState.failed => PrismIconButton(
                      icon: PrismIcons.undo,
                      tooltip: l.actionRetry,
                      onPressed: () {},
                    ),
                  },
                ),
            ],
          ),
      ],
    );
  }
}
