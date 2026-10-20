import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/site_visuals.dart';
import 'custom_search_sheet.dart';

class SearchEngineScreen extends ConsumerWidget {
  const SearchEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PrismPage(
      title: l.settingsSearch,
      children: [
        const SearchEngineList(),
        PrismSection(
          children: [
            PrismSwitchTile(
              icon: PrismIcons.lightning,
              title: l.searchSuggestions,
              subtitle: l.searchSuggestionsSub,
              value: ref.watch(searchSuggestionsEnabledProvider),
              onChanged: ref
                  .read(searchSuggestionsEnabledProvider.notifier)
                  .set,
            ),
          ],
        ),
      ],
    );
  }
}

/// Engine choice list (also used by onboarding).
class SearchEngineList extends ConsumerWidget {
  const SearchEngineList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final current = ref.watch(searchEngineProvider);
    final custom = ref.watch(customSearchProvider);
    return PrismSection(
      children: [
        for (final e in SearchEngine.all)
          Semantics(
            selected: current == e.id,
            inMutuallyExclusiveGroup: true,
            child: PrismTile(
              leading: LetterFavicon(
                label: e.name,
                host: hostOf(e.queryTemplate),
                size: 40,
              ),
              title: e.name,
              subtitle: hostOf(e.queryTemplate),
              limitedLabel: null,
              onTap: () => ref.read(searchEngineProvider.notifier).set(e.id),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (e.privacyFriendly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PrismSpace.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: t.secure.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        l.searchPrivateBadge,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: t.secure),
                      ),
                    ),
                  const SizedBox(width: PrismSpace.sm),
                  current == e.id
                      ? const Icon(PrismIcons.success, size: 22)
                      : const SizedBox(width: 22),
                ],
              ),
            ),
          ),
        if (custom == null)
          PrismTile(
            icon: PrismIcons.link,
            tone: PrismBadgeTone.neutral,
            title: l.searchCustom,
            subtitle: l.searchCustomSub,
            chevron: true,
            onTap: () => showCustomSearchSheet(context),
          )
        else
          Semantics(
            selected: current == SearchEngineId.custom,
            inMutuallyExclusiveGroup: true,
            child: PrismTile(
              icon: PrismIcons.link,
              tone: PrismBadgeTone.neutral,
              title: custom.name,
              subtitle: hostOf(custom.queryTemplate.replaceFirst('%s', 'q')),
              onTap: () => ref
                  .read(searchEngineProvider.notifier)
                  .set(SearchEngineId.custom),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrismIconButton(
                    icon: PrismIcons.appearance,
                    tooltip: l.actionEdit,
                    onPressed: () => showCustomSearchSheet(context),
                  ),
                  current == SearchEngineId.custom
                      ? const Icon(PrismIcons.success, size: 22)
                      : const SizedBox(width: 22),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
