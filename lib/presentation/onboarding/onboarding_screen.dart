import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/settings/appearance_controller.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_segmented.dart';
import '../../core/design/tokens.dart';
import '../../domain/settings/appearance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../browser/start_page.dart';
import '../settings/appearance_widgets.dart';
import '../settings/privacy_screen.dart';
import '../settings/search_engine_screen.dart';

/// First-run flow: style (live previews of both), theme & color, privacy
/// profile, search engine. Every choice applies immediately.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.initialStep = 0});

  final int initialStep;

  static const steps = 4;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialStep,
  );
  late int _step = widget.initialStep;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int step) {
    final motion = PrismMotion.of(context);
    if (!motion.enabled) {
      _pages.jumpToPage(step);
    } else {
      _pages.animateToPage(
        step,
        duration: motion.slow,
        curve: PrismMotion.standard,
      );
    }
  }

  void _finish() {
    ref.read(appearanceProvider.notifier).completeOnboarding();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final last = _step == OnboardingScreen.steps - 1;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: PrismBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PrismSpace.lg,
                    PrismSpace.sm,
                    PrismSpace.sm,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l.obStep(_step + 1, OnboardingScreen.steps),
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: t.onSurfaceMuted),
                      ),
                      const Spacer(),
                      if (!last)
                        PrismButton(
                          label: l.obSkip,
                          variant: PrismButtonVariant.ghost,
                          onPressed: _finish,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() => _step = i),
                    children: const [
                      _StyleStep(),
                      _ThemeStep(),
                      _PrivacyStep(),
                      _SearchStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PrismSpace.lg,
                    PrismSpace.sm,
                    PrismSpace.lg,
                    PrismSpace.lg,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 112,
                        child: _step == 0
                            ? null
                            : PrismButton(
                                label: l.obBack,
                                variant: PrismButtonVariant.ghost,
                                onPressed: () => _go(_step - 1),
                              ),
                      ),
                      Expanded(child: _Dots(step: _step)),
                      SizedBox(
                        width: 136,
                        child: PrismButton(
                          label: last ? l.obStart : l.obNext,
                          expand: true,
                          onPressed: last ? _finish : () => _go(_step + 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < OnboardingScreen.steps; i++)
            AnimatedContainer(
              duration: PrismMotion.of(context).medium,
              curve: PrismMotion.spring,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == step ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == step
                    ? t.onSurface
                    : t.onSurface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.body,
    required this.child,
    this.logo = false,
  });

  final String title;
  final String body;
  final Widget child;
  final bool logo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PrismSpace.lg,
            PrismSpace.lg,
            PrismSpace.lg,
            PrismSpace.lg,
          ),
          children: [
            if (logo) ...[
              const Center(
                child: SizedBox.square(dimension: 56, child: PrismLogo()),
              ),
              const SizedBox(height: PrismSpace.lg),
            ],
            Semantics(
              header: true,
              child: Text(
                title,
                style: text.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: PrismSpace.sm),
            Text(body, style: text.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: PrismSpace.xl),
            child,
          ],
        ),
      ),
    );
  }
}

class _StyleStep extends StatelessWidget {
  const _StyleStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _StepScaffold(
      logo: true,
      title: l.obWelcomeTitle,
      body: l.obWelcomeBody,
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StylePreviewCard(style: PrismStyleId.material)),
              SizedBox(width: PrismSpace.md),
              Expanded(child: StylePreviewCard(style: PrismStyleId.glass)),
            ],
          ),
          const SizedBox(height: PrismSpace.md),
          Text(l.obTryIt, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ThemeStep extends ConsumerWidget {
  const _ThemeStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(appearanceProvider);
    final c = ref.read(appearanceProvider.notifier);
    return _StepScaffold(
      title: l.obThemeTitle,
      body: l.obThemeBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrismSegmented<PrismThemeMode>(
            segments: [
              PrismSegment(value: PrismThemeMode.system, label: l.themeSystem),
              PrismSegment(value: PrismThemeMode.light, label: l.themeLight),
              PrismSegment(value: PrismThemeMode.dark, label: l.themeDark),
            ],
            selected: s.themeMode,
            onChanged: c.setThemeMode,
          ),
          const SizedBox(height: PrismSpace.lg),
          const Center(child: AccentPicker()),
          const SizedBox(height: PrismSpace.lg),
          Center(
            child: SizedBox(
              width: 200,
              child: StylePreviewCard(style: s.style),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyStep extends StatelessWidget {
  const _PrivacyStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _StepScaffold(
      title: l.obPrivacyTitle,
      body: l.obPrivacyBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfilePicker(),
          Text(
            l.noTelemetry,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SearchStep extends StatelessWidget {
  const _SearchStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _StepScaffold(
      title: l.obSearchTitle,
      body: l.obSearchBody,
      child: const SearchEngineList(),
    );
  }
}
