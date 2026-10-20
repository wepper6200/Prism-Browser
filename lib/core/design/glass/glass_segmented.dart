import 'package:material_ui/material_ui.dart';

import '../components/prism_segmented.dart';
import '../tokens.dart';
import 'glass_pill.dart';

/// Liquid Glass segmented control: a recessed clear capsule with an
/// accent-tinted lens that springs to the selected segment. Selection is
/// conveyed by the lens (shape), weight and contrast, not by hue alone, and
/// exposed to screen readers as a mutually exclusive selected button.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({super.key, required this.control});

  final PrismSegmented<T> control;

  static const double _inset = 4;

  @override
  Widget build(BuildContext context) {
    final segments = control.segments;
    final n = segments.length;
    final index = segments.indexWhere((s) => s.value == control.selected);
    final motion = PrismMotion.of(context);

    return GlassPill(
      tone: GlassTone.recessed,
      child: Padding(
        padding: const EdgeInsets.all(_inset),
        child: SizedBox(
          height: PrismSpace.touch,
          child: Stack(
            children: [
              if (index >= 0)
                AnimatedAlign(
                  alignment: Alignment(
                    n == 1 ? 0 : -1 + 2 * index / (n - 1),
                    0,
                  ),
                  duration: motion.slow,
                  curve: PrismMotion.spring,
                  child: FractionallySizedBox(
                    widthFactor: 1 / n,
                    heightFactor: 1,
                    child: const GlassPill(tone: GlassTone.accent),
                  ),
                ),
              Row(
                children: [
                  for (final s in segments)
                    Expanded(
                      child: _Segment<T>(
                        segment: s,
                        selected: s.value == control.selected,
                        onTap: () => control.onChanged(s.value),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final PrismSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final lens = GlassPillStyle.resolve(t, GlassTone.accent);
    final color = selected ? lens.foreground : t.onSurfaceMuted;
    final base = Theme.of(context).textTheme.labelLarge!;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          splashColor: t.onSurface.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PrismSpace.sm),
              child: AnimatedDefaultTextStyle(
                duration: PrismMotion.of(context).medium,
                style: base.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (segment.icon != null) ...[
                      Icon(segment.icon, size: 18, color: color),
                      const SizedBox(width: PrismSpace.sm),
                    ],
                    Flexible(
                      child: Text(
                        segment.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
