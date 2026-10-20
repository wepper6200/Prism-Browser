import 'package:flutter/widgets.dart';

import '../prism_design.dart';

/// Shows a style-appropriate modal sheet. Screens call this instead of
/// `showModalBottomSheet` so the active [PrismDesign] decides how it looks.
Future<T?> showPrismSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) =>
    PrismDesign.of(context)
        .showSheet<T>(context, builder: builder, title: title);
