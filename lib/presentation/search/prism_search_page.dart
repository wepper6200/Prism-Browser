import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/search/calculator.dart';
import '../../domain/search/prism_search.dart';
import '../../l10n/gen/app_localizations.dart';
import '../browser/start_page.dart';
import '../common/site_visuals.dart';

/// Prism Search results: a native page in the tab. Instant answers first
/// (calculator, Wikipedia), then the way out to full web results, then
/// what is already on the device.
class PrismSearchPage extends ConsumerWidget {
  const PrismSearchPage({
    super.key,
    required this.query,
    required this.topInset,
    required this.bottomInset,
  });

  final String query;
  final double topInset;
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final calc = Calculator.tryEvaluate(query);
    final local = ref.watch(localMatchesProvider(query));
    final wikiOn = ref.watch(instantAnswersProvider);
    final knowledge = wikiOn
        ? ref.watch(knowledgeProvider((query, lang)))
        : const AsyncData<List<KnowledgePage>>([]);
    final pages = knowledge.value ?? const <KnowledgePage>[];
    final nothing =
        calc == null && local.isEmpty && !knowledge.isLoading && pages.isEmpty;

    return Stack(
      children: [
        const Positioned.fill(child: PrismBackground()),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                PrismSpace.lg,
                topInset + PrismSpace.lg,
                PrismSpace.lg,
                bottomInset + PrismSpace.xl,
              ),
              children: [
                _Header(query: query),
                const SizedBox(height: PrismSpace.lg),
                if (calc != null) ...[
                  _CalculatorCard(expression: query, value: calc),
                  const SizedBox(height: PrismSpace.lg),
                ],
                if (wikiOn)
                  switch (knowledge) {
                    AsyncData(:final value) when value.isNotEmpty => Padding(
                      padding: const EdgeInsets.only(bottom: PrismSpace.lg),
                      child: _AnswerCard(page: value.first),
                    ),
                    AsyncError() => Padding(
                      padding: const EdgeInsets.only(bottom: PrismSpace.lg),
                      child: _InlineNote(
                        text: l.psWikiError,
                        onRetry: () =>
                            ref.invalidate(knowledgeProvider((query, lang))),
                      ),
                    ),
                    AsyncLoading() => const Padding(
                      padding: EdgeInsets.only(bottom: PrismSpace.lg),
                      child: _AnswerSkeleton(),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                if (nothing)
                  PrismEmptyState(
                    icon: PrismIcons.search,
                    title: l.psNothingTitle,
                    body: l.psNothingBody,
                  ),
                _WebSearch(query: query),
                if (local.isNotEmpty)
                  PrismSection(
                    title: l.psOnDevice,
                    children: [for (final m in local) _LocalTile(match: m)],
                  ),
                if (pages.length > 1)
                  PrismSection(
                    title: l.psMoreWiki,
                    children: [
                      for (final p in pages.skip(1)) _WikiTile(page: p),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PrismSpace.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          PrismIcons.shield,
                          size: 16,
                          color: PrismTokens.of(context).onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(width: PrismSpace.sm),
                      Expanded(child: Text(l.psPrivacy, style: text.bodySmall)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox.square(dimension: 20, child: PrismLogo()),
            const SizedBox(width: PrismSpace.sm),
            Text(
              'Prism Search',
              style: text.labelLarge?.copyWith(color: t.onSurfaceMuted),
            ),
          ],
        ),
        const SizedBox(height: PrismSpace.sm),
        Semantics(
          header: true,
          child: Text(
            query,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: text.headlineSmall?.copyWith(color: t.onSurface),
          ),
        ),
      ],
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.expression, required this.value});

  final String expression;
  final double value;

  static String format(double v, String locale) {
    if (v.abs() >= 1e15 || (v != 0 && v.abs() < 1e-9)) {
      return v.toStringAsExponential(6);
    }
    return (NumberFormat.decimalPattern(
      locale,
    )..maximumFractionDigits = 10).format(v);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final result = format(value, Localizations.localeOf(context).toString());
    return PrismSurface(
      kind: PrismSurfaceKind.card,
      padding: const EdgeInsets.fromLTRB(
        PrismSpace.lg,
        PrismSpace.md,
        PrismSpace.sm,
        PrismSpace.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.psCalculator.toUpperCase(), style: text.labelSmall),
                const SizedBox(height: PrismSpace.sm),
                Text(
                  '${expression.trim().replaceFirst(RegExp(r'\s*=$'), '')} =',
                  style: text.bodyLarge?.copyWith(color: t.onSurfaceMuted),
                ),
                const SizedBox(height: PrismSpace.xs),
                SelectableText(
                  result,
                  style: text.displaySmall?.copyWith(
                    color: t.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          PrismIconButton(
            icon: PrismIcons.copy,
            tooltip: l.psCopy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result)).ignore();
              ScaffoldMessenger.maybeOf(context)
                  ?.showSnackBar(SnackBar(content: Text(l.psCopied)));
            },
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends ConsumerWidget {
  const _AnswerCard({required this.page});

  final KnowledgePage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final thumb = page.thumbnail;
    return PrismSurface(
      kind: PrismSurfaceKind.card,
      padding: const EdgeInsets.all(PrismSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(page.title, style: text.titleLarge),
                    if (page.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        page.description,
                        style: text.bodyMedium?.copyWith(
                          color: t.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (thumb != null) ...[
                const SizedBox(width: PrismSpace.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(t.radiusSm),
                  child: Image.network(
                    thumb.toString(),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    // Decorative: the title says what it is.
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
          if (page.extract.isNotEmpty) ...[
            const SizedBox(height: PrismSpace.md),
            Text(
              page.extract,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: text.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
          const SizedBox(height: PrismSpace.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: PrismSpace.md,
            runSpacing: PrismSpace.sm,
            children: [
              Text(l.psWikiAttribution, style: text.bodySmall),
              PrismButton(
                label: l.psReadMore,
                icon: PrismIcons.external,
                variant: PrismButtonVariant.secondary,
                onPressed: () =>
                    ref.read(browserActionsProvider).openUri(page.url).ignore(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Static placeholder while Wikipedia answers (no shimmer: nothing moves
/// under the glass chrome, so it costs no frames).
class _AnswerSkeleton extends StatelessWidget {
  const _AnswerSkeleton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: PrismSpace.sm),
        decoration: BoxDecoration(
          color: t.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
    return Semantics(
      label: l.psLoading,
      liveRegion: true,
      child: PrismSurface(
        kind: PrismSurfaceKind.card,
        padding: const EdgeInsets.all(PrismSpace.lg),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(0.45, 22),
              bar(0.3, 14),
              const SizedBox(height: PrismSpace.sm),
              bar(1, 14),
              bar(0.95, 14),
              bar(0.7, 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    return PrismSurface(
      kind: PrismSurfaceKind.card,
      padding: const EdgeInsets.fromLTRB(
        PrismSpace.lg,
        PrismSpace.sm,
        PrismSpace.sm,
        PrismSpace.sm,
      ),
      child: Row(
        children: [
          Icon(PrismIcons.info, size: 20, color: t.onSurfaceMuted),
          const SizedBox(width: PrismSpace.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
          PrismButton(
            label: l.actionRetry,
            variant: PrismButtonVariant.ghost,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _WebSearch extends ConsumerWidget {
  const _WebSearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final engines = ref.watch(webSearchEnginesProvider);
    final actions = ref.read(browserActionsProvider);
    final main = engines.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PrismSpace.xs,
              0,
              PrismSpace.xs,
              PrismSpace.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(l.psSearchWeb.toUpperCase(), style: text.labelSmall),
            ),
          ),
          PrismButton(
            label: l.omniboxSearchWith(main.name),
            icon: PrismIcons.search,
            expand: true,
            onPressed: () => actions.searchWeb(query, main).ignore(),
          ),
          const SizedBox(height: PrismSpace.md),
          Wrap(
            spacing: PrismSpace.sm,
            runSpacing: PrismSpace.sm,
            children: [
              for (final e in engines.skip(1))
                PrismChip(
                  label: e.name,
                  onTap: () => actions.searchWeb(query, e).ignore(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalTile extends ConsumerWidget {
  const _LocalTile({required this.match});

  final LocalMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final kind = switch (match.kind) {
      LocalMatchKind.tab => l.psKindTab,
      LocalMatchKind.bookmark => l.psKindBookmark,
      LocalMatchKind.history => l.psKindHistory,
    };
    final host = hostOf(match.url);
    return PrismTile(
      leading: LetterFavicon(label: match.title, host: host, size: 40),
      title: match.title,
      subtitle: '$kind · $host',
      chevron: true,
      onTap: () {
        final tabId = match.tabId;
        if (tabId != null) {
          ref.read(tabsProvider.notifier).select(tabId);
        } else {
          final uri = Uri.tryParse(match.url);
          if (uri != null) {
            ref.read(browserActionsProvider).openUri(uri).ignore();
          }
        }
      },
    );
  }
}

class _WikiTile extends ConsumerWidget {
  const _WikiTile({required this.page});

  final KnowledgePage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = page.description.isNotEmpty
        ? page.description
        : page.extract;
    return PrismTile(
      icon: PrismIcons.reader,
      tone: PrismBadgeTone.neutral,
      title: page.title,
      subtitle: subtitle.isEmpty ? null : subtitle,
      chevron: true,
      onTap: () => ref.read(browserActionsProvider).openUri(page.url).ignore(),
    );
  }
}
