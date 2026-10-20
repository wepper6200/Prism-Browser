import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/site_visuals.dart';

class SearchEngineScreen extends ConsumerStatefulWidget {
  const SearchEngineScreen({super.key});

  @override
  ConsumerState<SearchEngineScreen> createState() => _SearchEngineScreenState();
}

class _SearchEngineScreenState extends ConsumerState<SearchEngineScreen> {
  bool _suggestions = true;

  @override
  Widget build(BuildContext context) {
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
              value: _suggestions,
              onChanged: (v) => setState(() => _suggestions = v),
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
        PrismTile(
          icon: PrismIcons.link,
          tone: PrismBadgeTone.neutral,
          title: l.searchCustom,
          subtitle: l.searchCustomSub,
          chevron: true,
          onTap: () {},
        ),
      ],
    );
  }
}
