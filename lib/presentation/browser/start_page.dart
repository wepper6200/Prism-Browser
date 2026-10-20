import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';

import '../../core/design/components/prism_address_field.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../data/mock/mock_data.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/site_visuals.dart';

/// New-tab page. Content scrolls under the chrome; insets keep it visible.
class StartPage extends StatelessWidget {
  const StartPage({
    super.key,
    required this.topInset,
    required this.bottomInset,
    required this.incognito,
    this.onSearchTap,
    this.onOpen,
  });

  final double topInset;
  final double bottomInset;
  final bool incognito;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Stack(
      children: [
        const Positioned.fill(child: PrismBackground()),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                PrismSpace.lg,
                topInset + PrismSpace.xxl,
                PrismSpace.lg,
                bottomInset + PrismSpace.xl,
              ),
              children: incognito
                  ? [const _IncognitoIntro()]
                  : [
                      const _Wordmark(),
                      const SizedBox(height: PrismSpace.xl),
                      PrismAddressField(
                        text: '',
                        hint: l.omniboxHint,
                        onTap: onSearchTap,
                      ),
                      const SizedBox(height: PrismSpace.xl),
                      Semantics(
                        header: true,
                        child: Text(
                          l.startTopSites.toUpperCase(),
                          style: text.labelSmall,
                        ),
                      ),
                      const SizedBox(height: PrismSpace.md),
                      _TopSites(onOpen: onOpen),
                      const SizedBox(height: PrismSpace.xl),
                      const _ProtectionCard(),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return Column(
      children: [
        const SizedBox.square(dimension: 64, child: PrismLogo()),
        const SizedBox(height: PrismSpace.md),
        Text(
          'Prism',
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: t.onSurface),
        ),
      ],
    );
  }
}

/// App mark: a glass triangle splitting light into a spectrum. Drawn in
/// code (no raster asset) so it stays crisp at any size.
class PrismLogo extends StatelessWidget {
  const PrismLogo({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      painter: _LogoPainter(PrismTokens.of(context).onSurface),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.edge);

  final Color edge;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final top = Offset(w * 0.5, w * 0.08);
    final left = Offset(w * 0.08, w * 0.86);
    final right = Offset(w * 0.92, w * 0.86);
    const spectrum = [
      Color(0xFFFF5F6D),
      Color(0xFFFFC371),
      Color(0xFF7CF29C),
      Color(0xFF38BDF8),
      Color(0xFF8B5CF6),
    ];
    final tri = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(
      tri,
      Paint()
        ..shader = ui.Gradient.linear(left, right, spectrum, const [
          0,
          0.25,
          0.5,
          0.75,
          1,
        ]),
    );
    canvas.drawPath(
      tri,
      Paint()
        ..shader = ui.Gradient.linear(top, Offset(w / 2, right.dy), [
          const Color(0x66FFFFFF),
          const Color(0x00FFFFFF),
        ]),
    );
    canvas.drawPath(
      tri,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeJoin = StrokeJoin.round
        ..color = edge.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.edge != edge;
}

class _TopSites extends StatelessWidget {
  const _TopSites({this.onOpen});

  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth > 520 ? 8 : 4;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: PrismSpace.md,
          crossAxisSpacing: PrismSpace.sm,
          childAspectRatio: 0.82,
          children: [
            for (final (name, url) in MockData.topSites)
              Semantics(
                button: true,
                label: name,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onOpen == null ? null : () => onOpen!(url),
                  child: Column(
                    children: [
                      PrismSurface(
                        kind: PrismSurfaceKind.card,
                        padding: const EdgeInsets.all(10),
                        child: LetterFavicon(
                          label: name,
                          host: hostOf(url),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: PrismSpace.xs + 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProtectionCard extends ConsumerWidget {
  const _ProtectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    // Real weekly counters come with the blocker (stage 5).
    final demo = ref.watch(demoDataProvider);
    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: text.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
    return PrismSurface(
      kind: PrismSurfaceKind.card,
      padding: const EdgeInsets.all(PrismSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PrismIcons.shield, color: t.secure, size: 20),
              const SizedBox(width: PrismSpace.sm),
              Text(l.startProtection, style: text.titleSmall),
            ],
          ),
          const SizedBox(height: PrismSpace.lg),
          Row(
            children: [
              stat(demo ? '1 284' : '0', l.statTrackers),
              stat(demo ? '312' : '0', l.statAds),
              stat(l.statTimeValue(demo ? 14 : 0), l.statTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncognitoIntro extends StatelessWidget {
  const _IncognitoIntro();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        const SizedBox(height: PrismSpace.xxl),
        const PrismIconBadge(
          icon: PrismIcons.incognito,
          tone: PrismBadgeTone.neutral,
          size: 72,
        ),
        const SizedBox(height: PrismSpace.lg),
        Text(l.incognitoTitle, style: text.headlineMedium),
        const SizedBox(height: PrismSpace.md),
        PrismSurface(
          kind: PrismSurfaceKind.card,
          padding: const EdgeInsets.all(PrismSpace.lg),
          child: Text(l.incognitoBody, style: text.bodyLarge),
        ),
      ],
    );
  }
}
