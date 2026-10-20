import 'package:material_ui/material_ui.dart';

import '../../data/engine/fake_page.dart';
import '../../domain/browser/models.dart';

/// Brand-ish colors for mock sites (favicons, thumbnails). Stage 3 replaces
/// letter favicons with real ones fetched by the engine.
Color siteColor(String host) {
  const known = {
    'wikipedia.org': Color(0xFF54595D),
    'ru.wikipedia.org': Color(0xFF54595D),
    'duckduckgo.com': Color(0xFFDE5833),
    'github.com': Color(0xFF24292F),
    'habr.com': Color(0xFF6A8FA6),
    'youtube.com': Color(0xFFE62117),
    'flutter.dev': Color(0xFF0468D7),
    'docs.flutter.dev': Color(0xFF0468D7),
    'm3.material.io': Color(0xFF6750A4),
    'yandex.ru': Color(0xFFFC3F1D),
    'market.yandex.ru': Color(0xFFFFCC00),
    'rzd.ru': Color(0xFFE21A1A),
    'openstreetmap.org': Color(0xFF7EBC6F),
    'ssd.eff.org': Color(0xFF2B6CB0),
  };
  final h = host.startsWith('www.') ? host.substring(4) : host;
  if (known.containsKey(h)) return known[h]!;
  const palette = [
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF6366F1),
  ];
  return palette[h.hashCode.abs() % palette.length];
}

String hostOf(String url) {
  final h = Uri.tryParse(url)?.host ?? url;
  return h.startsWith('www.') ? h.substring(4) : h;
}

/// Rounded letter favicon.
class LetterFavicon extends StatelessWidget {
  const LetterFavicon({
    super.key,
    required this.label,
    required this.host,
    this.size = 20,
  });

  final String label;
  final String host;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = siteColor(host);
    final letter = label.isEmpty ? '·' : label.characters.first.toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Text(
          letter,
          style: TextStyle(
            color: c.computeLuminance() > 0.6 ? Colors.black : Colors.white,
            fontSize: size * 0.55,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Cached-screenshot stand-in for tab cards.
class SiteThumbnail extends StatelessWidget {
  const SiteThumbnail({super.key, required this.tab});

  final BrowserTab tab;

  @override
  Widget build(BuildContext context) {
    if (tab.host.contains('wikipedia')) {
      return const FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 400,
          height: 640,
          child: MockWebPage(topInset: 0, bottomInset: 0),
        ),
      );
    }
    final c = siteColor(tab.host);
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 26, color: c),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(0.7, 10, const Color(0xFF1F2937)),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                for (final w in [0.95, 0.85, 0.9, 0.6]) ...[
                  _line(w, 6, const Color(0xFFCBD5E1)),
                  const SizedBox(height: 5),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double w, double h, Color c) => FractionallySizedBox(
    widthFactor: w,
    child: Container(
      height: h,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}
