@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';

import '../helpers/pump_app.dart';

/// Goldens are generated on Windows (`flutter test --update-goldens
/// --tags golden`). Font rasterisation differs per OS, so CI runs them only
/// on windows-latest.
void main() {
  for (final style in PrismStyleId.values) {
    for (final mode in [PrismThemeMode.dark, PrismThemeMode.light]) {
      testWidgets('gallery ${style.name} ${mode.name}', (tester) async {
        await pumpPrismApp(
          tester,
          settings: AppearanceSettings(style: style, themeMode: mode),
        );
        await expectLater(
          find.byType(PrismApp),
          matchesGoldenFile('goldens/gallery_${style.name}_${mode.name}.png'),
        );
      });
    }
  }
}
