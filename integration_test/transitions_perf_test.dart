import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prism_browser/application/settings/appearance_controller.dart';
import 'package:prism_browser/domain/settings/appearance.dart';
import 'package:prism_browser/presentation/app/prism_app.dart';
import 'package:prism_browser/presentation/browser/browser_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Frame timings of screen transitions on a real device, profile mode:
///   flutter drive --profile --driver=test_driver/perf_driver.dart
///     --target=integration_test/transitions_perf_test.dart -d DEVICE
/// Results: build/transitions_STYLE.json. Uses engine FrameTimings directly
/// (no VM service connection, which proxies/port-forwarding can break).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final reports = <String, dynamic>{};

  Map<String, num> summarize(List<FrameTiming> frames) {
    double ms(Duration d) => d.inMicroseconds / 1000;
    List<double> sorted(Iterable<double> v) => v.toList()..sort();
    double pct(List<double> v, double p) =>
        v.isEmpty ? 0 : v[((v.length - 1) * p).round()];
    final build = sorted(frames.map((f) => ms(f.buildDuration)));
    final raster = sorted(frames.map((f) => ms(f.rasterDuration)));
    final total = sorted(frames.map((f) => ms(f.totalSpan)));
    double avg(List<double> v) =>
        v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
    return {
      'frames': frames.length,
      'build_avg_ms': avg(build),
      'build_p90_ms': pct(build, 0.9),
      'raster_avg_ms': avg(raster),
      'raster_p90_ms': pct(raster, 0.9),
      'raster_p99_ms': pct(raster, 0.99),
      'raster_max_ms': raster.isEmpty ? 0 : raster.last,
      'total_p90_ms': pct(total, 0.9),
      // Budget 16.7 ms (60 Hz).
      'janky_frames_pct': frames.isEmpty
          ? 0
          : 100 * total.where((t) => t > 16.7).length / frames.length,
    };
  }

  for (final style in PrismStyleId.values) {
    testWidgets('transitions ${style.name}', (tester) async {
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      c
          .read(appearanceProvider.notifier)
          .update((s) => s.copyWith(style: style, onboardingDone: true));
      await tester.pumpWidget(
        UncontrolledProviderScope(container: c, child: const PrismApp()),
      );
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(BrowserScreen)));

      final frames = <FrameTiming>[];
      void collect(List<FrameTiming> t) => frames.addAll(t);
      SchedulerBinding.instance.addTimingsCallback(collect);
      for (var i = 0; i < 3; i++) {
        for (final route in ['/downloads', '/history', '/settings']) {
          router.push(route).ignore();
          await tester.pumpAndSettle();
          router.pop();
          await tester.pumpAndSettle();
        }
      }
      // Timings are delivered in batches; let the last ones arrive.
      await tester.pump(const Duration(seconds: 1));
      SchedulerBinding.instance.removeTimingsCallback(collect);

      reports['transitions_${style.name}'] = summarize(frames);
      binding.reportData = reports;
      c.dispose();
    });
  }
}
