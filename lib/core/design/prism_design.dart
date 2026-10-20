import 'package:material_ui/material_ui.dart';

import '../../domain/settings/appearance.dart';
import 'components/prism_address_field.dart';
import 'components/prism_button.dart';
import 'components/prism_controls.dart';
import 'components/prism_segmented.dart';
import 'components/prism_surface.dart';
import 'components/prism_tab_card.dart';
import 'components/prism_toolbar.dart';

/// Input needed to build a [ThemeData] for one brightness.
@immutable
class PrismThemeInput {
  const PrismThemeInput({
    required this.brightness,
    required this.seed,
    required this.density,
  });

  final Brightness brightness;

  /// User accent, or the wallpaper / system accent color when dynamic
  /// color is enabled. Schemes are always built with [ColorScheme.fromSeed]
  /// so every M3 role (surfaceContainer*, etc.) is populated.
  final Color seed;
  final UiDensity density;
}

/// One complete visual style: tokens + component renderers.
///
/// Screens only use `Prism*` widgets; those delegate rendering to the active
/// [PrismDesign] found through [PrismDesignScope]. To add a third style,
/// implement this class and register it in `design_registry.dart`.
abstract class PrismDesign {
  const PrismDesign();

  PrismStyleId get id;

  ThemeData buildTheme(PrismThemeInput input);

  Widget buildSurface(BuildContext context, PrismSurface surface);

  Widget buildToolbar(BuildContext context, PrismToolbar toolbar);

  Widget buildTabCard(BuildContext context, PrismTabCard card);

  Widget buildButton(BuildContext context, PrismButton button);

  Widget buildIconButton(BuildContext context, PrismIconButton button);

  Widget buildAddressField(BuildContext context, PrismAddressField field);

  Widget buildSegmented<T>(BuildContext context, PrismSegmented<T> control);

  Widget buildBackground(BuildContext context);

  Widget buildIconBadge(BuildContext context, PrismIconBadge badge);

  Widget buildChip(BuildContext context, PrismChip chip);

  Widget buildSearchField(BuildContext context, PrismSearchField field);

  /// Modal bottom sheet (phones) / anchored panel (wide screens).
  Future<T?> showSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
  });

  static PrismDesign of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PrismDesignScope>();
    assert(scope != null, 'No PrismDesignScope above this context');
    return scope!.design;
  }
}

class PrismDesignScope extends InheritedWidget {
  const PrismDesignScope({
    super.key,
    required this.design,
    required super.child,
  });

  final PrismDesign design;

  @override
  bool updateShouldNotify(PrismDesignScope oldWidget) =>
      design.id != oldWidget.design.id;
}
