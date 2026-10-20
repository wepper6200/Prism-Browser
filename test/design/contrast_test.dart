import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/core/design/design_registry.dart';
import 'package:prism_browser/core/design/glass/glass_pill.dart';
import 'package:prism_browser/core/design/prism_design.dart';
import 'package:prism_browser/core/design/tokens.dart';
import 'package:prism_browser/domain/settings/appearance.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

void main() {
  const seeds = [
    AppearanceSettings.defaultSeed,
    0xFF0EA5E9, // sky
    0xFF22C55E, // green
    0xFFF97316, // orange
    0xFFE11D48, // rose
  ];

  for (final style in PrismStyleId.values) {
    for (final brightness in Brightness.values) {
      for (final seed in seeds) {
        final name =
            '${style.name}/${brightness.name}/'
            '0x${seed.toRadixString(16)}';
        final theme = designFor(style).buildTheme(
          PrismThemeInput(
            brightness: brightness,
            seed: Color(seed),
            density: UiDensity.comfortable,
          ),
        );
        final t = theme.extension<PrismTokens>()!;

        test('$name: text on opaque surfaces is WCAG AA', () {
          for (final bg in [t.canvas, t.surface, t.surfaceRaised]) {
            expect(contrast(t.onSurface, bg), greaterThanOrEqualTo(4.5));
            expect(contrast(t.onSurfaceMuted, bg), greaterThanOrEqualTo(4.5));
          }
          expect(contrast(t.onAccent, t.accent), greaterThanOrEqualTo(4.5));
        });

        test('$name: status colors are >= 3:1 (icons, paired with text)', () {
          for (final c in [t.secure, t.warning, t.danger]) {
            expect(contrast(c, t.surface), greaterThanOrEqualTo(3));
          }
        });

        if (t.isGlass) {
          test('$name: text on glass over the Prism backdrop is WCAG AA', () {
            // Worst case = un-blurred peak of each backdrop blob.
            final blobAlpha = brightness == Brightness.dark ? 0.55 : 0.35;
            final blobs = [
              t.accent,
              const Color(0xFF22D3EE),
              const Color(0xFFF472B6),
            ];
            for (final blob in blobs) {
              final backdrop = over(
                blob.withValues(alpha: blobAlpha),
                t.canvas,
              );
              final glass = over(t.glassTint, backdrop);
              expect(
                contrast(t.onSurfaceMuted, glass),
                greaterThanOrEqualTo(4.5),
                reason: 'muted text over blob $blob',
              );
              expect(contrast(t.onSurface, glass), greaterThanOrEqualTo(4.5));
            }
          });

          test('$name: text on glass pills (buttons, segments) is WCAG AA', () {
            final blobAlpha = brightness == Brightness.dark ? 0.55 : 0.35;
            final backdrops = [
              t.canvas,
              for (final blob in [
                t.accent,
                const Color(0xFF22D3EE),
                const Color(0xFFF472B6),
              ])
                over(blob.withValues(alpha: blobAlpha), t.canvas),
            ];
            for (final tone in GlassTone.values) {
              final p = GlassPillStyle.resolve(t, tone);
              for (final backdrop in backdrops) {
                // Pill sits on a glass panel/bar over the backdrop.
                final panel = over(t.glassTint, backdrop);
                for (final fill in [p.fillTop, p.fillBottom]) {
                  expect(
                    contrast(p.foreground, over(fill, panel)),
                    greaterThanOrEqualTo(4.5),
                    reason: '$tone over $backdrop',
                  );
                }
              }
            }
          });
        }
      }
    }
  }
}
