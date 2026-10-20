import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_surface.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../data/mock/mock_data.dart';
import '../../domain/engine/url_resolver.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/site_visuals.dart';

/// Focused omnibox: editing field + suggestions. Stage 6 morphs the
/// resting address pill into this panel; stage 2 cross-fades.
class OmniboxPanel extends ConsumerStatefulWidget {
  const OmniboxPanel({
    super.key,
    required this.initialText,
    required this.onClose,
    required this.onSubmit,
  });

  final String initialText;
  final VoidCallback onClose;
  final ValueChanged<String> onSubmit;

  @override
  ConsumerState<OmniboxPanel> createState() => _OmniboxPanelState();
}

class _OmniboxPanelState extends ConsumerState<OmniboxPanel> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initialText.length,
        );

  final _focus = FocusNode(debugLabel: 'omnibox');

  @override
  void initState() {
    super.initState();
    // Explicit request: `autofocus` is ignored when the browser screen's
    // shortcut Focus already owns focus in this scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final query = _controller.text;
    final engine = ref.watch(activeSearchEngineProvider);
    final suggestions = ref.watch(omniboxSuggestionsProvider(query));
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        Positioned.fill(
          // Tap-outside-to-dismiss scrim, announced like a modal barrier.
          child: Semantics(
            button: true,
            label: l.actionClose,
            child: GestureDetector(
              onTap: widget.onClose,
              child: ColoredBox(color: t.scrim.withValues(alpha: 0.45)),
            ),
          ),
        ),
        Positioned.fill(
          top: 0,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    PrismSpace.md,
                    top > 0 ? PrismSpace.sm : PrismSpace.md,
                    PrismSpace.md,
                    PrismSpace.md,
                  ),
                  child: PrismSurface(
                    kind: PrismSurfaceKind.panel,
                    padding: const EdgeInsets.all(PrismSpace.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: PrismSearchField(
                                controller: _controller,
                                focusNode: _focus,
                                hint: l.omniboxHint,
                                leading: PrismIcons.globe,
                                keyboardType: TextInputType.url,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: widget.onSubmit,
                                trailing: query.isEmpty
                                    ? null
                                    : PrismIconButton(
                                        icon: PrismIcons.close,
                                        tooltip: l.actionClearQuery,
                                        onPressed: () =>
                                            setState(_controller.clear),
                                      ),
                              ),
                            ),
                            const SizedBox(width: PrismSpace.xs),
                            PrismButton(
                              label: l.actionCancel,
                              variant: PrismButtonVariant.ghost,
                              onPressed: widget.onClose,
                            ),
                          ],
                        ),
                        const SizedBox(height: PrismSpace.sm),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              if (query.isNotEmpty &&
                                  UrlResolver.looksLikeAddress(query))
                                _SuggestionRow(
                                  icon: PrismIcons.globe,
                                  title: query,
                                  subtitle: l.omniboxGoTo,
                                  query: query,
                                  onTap: () => widget.onSubmit(query),
                                )
                              else if (query.isNotEmpty)
                                _SuggestionRow(
                                  icon: PrismIcons.search,
                                  title: query,
                                  subtitle: l.omniboxSearchWith(engine.name),
                                  query: query,
                                  onTap: () => widget.onSubmit(query),
                                ),
                              for (final s in suggestions)
                                _SuggestionRow(
                                  icon: switch (s.kind) {
                                    SuggestionKind.search => PrismIcons.search,
                                    SuggestionKind.history =>
                                      PrismIcons.history,
                                    SuggestionKind.bookmark =>
                                      PrismIcons.bookmark,
                                  },
                                  title: s.title,
                                  subtitle: s.url == null
                                      ? l.suggestionSearch
                                      : hostOf(s.url!),
                                  query: query,
                                  onTap: () =>
                                      widget.onSubmit(s.url ?? s.title),
                                  onFill: () => setState(() {
                                    _controller.text = s.url ?? s.title;
                                    _controller.selection =
                                        TextSelection.collapsed(
                                          offset: _controller.text.length,
                                        );
                                  }),
                                ),
                              if (query.isEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    PrismSpace.md,
                                    PrismSpace.sm,
                                    PrismSpace.md,
                                    PrismSpace.sm,
                                  ),
                                  child: Text(
                                    l.startTopSites.toUpperCase(),
                                    style: text.labelSmall,
                                  ),
                                ),
                                Wrap(
                                  spacing: PrismSpace.sm,
                                  children: [
                                    for (final (name, url)
                                        in MockData.topSites.take(6))
                                      PrismChip(
                                        label: name,
                                        onTap: () => widget.onSubmit(url),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: PrismSpace.sm),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.query,
    required this.onTap,
    this.onFill,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String query;
  final VoidCallback onTap;
  final VoidCallback? onFill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusMd),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PrismSpace.md),
          child: Row(
            children: [
              Icon(icon, size: 20, color: t.onSurfaceMuted),
              const SizedBox(width: PrismSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      _highlight(title, query, text.bodyLarge!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onFill != null)
                PrismIconButton(
                  icon: PrismIcons.fillQuery,
                  tooltip: l.omniboxFill,
                  onPressed: onFill,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bold the matched part so users see why a row was suggested.
  static TextSpan _highlight(String s, String q, TextStyle base) {
    final i = q.isEmpty ? -1 : s.toLowerCase().indexOf(q.toLowerCase());
    if (i < 0) return TextSpan(text: s, style: base);
    return TextSpan(
      style: base,
      children: [
        TextSpan(text: s.substring(0, i)),
        TextSpan(
          text: s.substring(i, i + q.length),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: s.substring(i + q.length)),
      ],
    );
  }
}
