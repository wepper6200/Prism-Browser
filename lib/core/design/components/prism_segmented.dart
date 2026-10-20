import 'package:flutter/widgets.dart';

import '../prism_design.dart';

@immutable
class PrismSegment<T> {
  const PrismSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Single-choice segmented control (style, theme, language...).
/// Glass: clear capsule with a sliding accent lens. Material: M3
/// SegmentedButton with a checkmark on the selected segment.
class PrismSegmented<T> extends StatelessWidget {
  const PrismSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<PrismSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildSegmented<T>(context, this);
}
