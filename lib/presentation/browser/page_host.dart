import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';

/// Hosts the active tab's engine view. Warms the engine up lazily (first
/// page only), then shows the page, or an actionable error instead of a
/// blank screen.
class PageHost extends ConsumerStatefulWidget {
  const PageHost({super.key, required this.tabId, required this.insets});

  final String tabId;

  /// Chrome overlapping the page (top bar, bottom bars).
  final EdgeInsets insets;

  @override
  ConsumerState<PageHost> createState() => _PageHostState();
}

class _PageHostState extends ConsumerState<PageHost> {
  late final Future<void> _warm = ref.read(engineProvider).warmUp();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<void>(
      future: _warm,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.expand();
        }
        final engine = ref.read(engineProvider);
        if (!engine.isAvailable) {
          return _ErrorCard(
            insets: widget.insets,
            title: l.errorEngineMissingTitle,
            body: l.errorEngineMissingBody,
          );
        }
        final session = ref.watch(sessionProvider(widget.tabId));
        final error = ref.watch(
          sessionStateProvider(widget.tabId).select((s) => s.error),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            // Stable key: the native view (kept alive per session) is never
            // recreated by chrome rebuilds.
            KeyedSubtree(
              key: ValueKey('page-${widget.tabId}'),
              child: session.buildView(context, widget.insets),
            ),
            if (error != null)
              _ErrorCard(
                insets: widget.insets,
                title: l.errorPageTitle,
                body: error,
                onRetry: () =>
                    ref.read(browserActionsProvider).reload().ignore(),
              ),
          ],
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.insets,
    required this.title,
    required this.body,
    this.onRetry,
  });

  final EdgeInsets insets;
  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        const PrismBackground(),
        Padding(
          padding: insets + const EdgeInsets.all(PrismSpace.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: PrismSurface(
                kind: PrismSurfaceKind.card,
                padding: const EdgeInsets.all(PrismSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PrismIconBadge(
                      icon: PrismIcons.warning,
                      tone: PrismBadgeTone.warning,
                      size: 56,
                    ),
                    const SizedBox(height: PrismSpace.lg),
                    Text(
                      title,
                      style: text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PrismSpace.sm),
                    Text(
                      body,
                      style: text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: PrismSpace.lg),
                      PrismButton(
                        label: l.actionRetry,
                        icon: PrismIcons.reload,
                        onPressed: onRetry,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
