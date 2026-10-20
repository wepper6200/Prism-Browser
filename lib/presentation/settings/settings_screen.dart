import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/prism_icons.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final engine = SearchEngine.byId(ref.watch(searchEngineProvider));
    final android = defaultTargetPlatform == TargetPlatform.android;
    return PrismPage(
      title: l.settingsTitle,
      children: [
        PrismSection(
          title: l.settingsGeneral,
          children: [
            PrismTile(
              icon: PrismIcons.search,
              title: l.settingsSearch,
              subtitle: engine.name,
              chevron: true,
              onTap: () => context.push('/settings/search'),
            ),
            PrismTile(
              icon: android ? PrismIcons.phone : PrismIcons.desktop,
              title: l.settingsDefaultBrowser,
              subtitle: l.settingsDefaultBrowserSub,
              trailing: const Icon(PrismIcons.external, size: 18),
              // Opens the system default-apps screen (stage 3).
              onTap: () {},
            ),
          ],
        ),
        PrismSection(
          children: [
            PrismTile(
              icon: PrismIcons.appearance,
              title: l.settingsAppearance,
              subtitle: l.settingsAppearanceSub,
              chevron: true,
              onTap: () => context.push('/settings/appearance'),
            ),
            PrismTile(
              icon: PrismIcons.shield,
              tone: PrismBadgeTone.secure,
              title: l.settingsPrivacy,
              subtitle: l.settingsPrivacySub,
              chevron: true,
              onTap: () => context.push('/settings/privacy'),
            ),
            PrismTile(
              icon: PrismIcons.key,
              title: l.settingsPermissions,
              subtitle: l.settingsPermissionsSub,
              chevron: true,
              onTap: () => context.push('/settings/permissions'),
            ),
          ],
        ),
        PrismSection(
          footer: l.noTelemetry,
          children: [
            PrismTile(
              icon: PrismIcons.swatches,
              tone: PrismBadgeTone.neutral,
              title: l.settingsDesign,
              chevron: true,
              onTap: () => context.push('/settings/design'),
            ),
            PrismTile(
              icon: PrismIcons.info,
              tone: PrismBadgeTone.neutral,
              title: l.settingsAbout,
              subtitle: l.settingsAboutSub('0.2.0'),
            ),
          ],
        ),
      ],
    );
  }
}
