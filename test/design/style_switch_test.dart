import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prism_browser/application/settings/appearance_controller.dart';
import 'package:prism_browser/core/design/glass/glass_material.dart';
import 'package:prism_browser/core/design/prism_design.dart';
import 'package:prism_browser/core/design/tokens.dart';
import 'package:prism_browser/domain/settings/appearance.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('switching style at runtime swaps design without restart', (
    tester,
  ) async {
    final container = await pumpPrismApp(tester);
    expect(find.byType(GlassMaterial), findsWidgets);

    await tester.tap(find.text('Material 3'));
    await tester.pumpAndSettle();

    expect(container.read(appearanceProvider).style, PrismStyleId.material);
    expect(find.byType(GlassMaterial), findsNothing);
    final ctx = tester.element(find.text('Material 3'));
    expect(PrismDesign.of(ctx).id, PrismStyleId.material);
    expect(PrismTokens.of(ctx).isGlass, isFalse);
  });

  testWidgets('theme switch animates tokens (interruptible lerp)', (
    tester,
  ) async {
    await pumpPrismApp(tester);
    // Read app-level tokens (Scaffold), not from inside a button: material_ui
    // buttons wrap their content in their own AnimatedTheme.
    Color canvas() =>
        PrismTokens.of(tester.element(find.byType(Scaffold))).canvas;
    final darkCanvas = canvas();

    await tester.tap(find.text('Светлая'));
    await tester.pump(); // frame that starts the theme animation
    await tester.pump(const Duration(milliseconds: 250));
    final mid = canvas();
    await tester.pumpAndSettle();
    final light = canvas();

    expect(mid, isNot(darkCanvas));
    expect(mid, isNot(light));
    expect(light.computeLuminance(), greaterThan(0.5));
  });

  testWidgets('reduce motion makes theme switch instant', (tester) async {
    await pumpPrismApp(
      tester,
      settings: const AppearanceSettings(reduceMotion: true),
    );
    await tester.tap(find.text('Светлая'));
    await tester.pump();
    final t = PrismTokens.of(tester.element(find.byType(Scaffold)));
    expect(t.canvas.computeLuminance(), greaterThan(0.5));
  });

  testWidgets('icon buttons expose labels and 48dp targets', (tester) async {
    await pumpPrismApp(tester);
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    expect(find.byTooltip('Вкладки'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('English locale', (tester) async {
    await pumpPrismApp(tester, locale: const Locale('en'));
    expect(find.text('Design system'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
