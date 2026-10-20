import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_segmented.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/site_visuals.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  // Stage 2: in-memory defaults; stage 5 persists and enforces them.
  final Map<SitePermissionKind, PermissionDecision> _defaults = {
    for (final k in SitePermissionKind.values)
      k: k == SitePermissionKind.popups
          ? PermissionDecision.block
          : PermissionDecision.ask,
  };

  static IconData iconOf(SitePermissionKind k) => switch (k) {
    SitePermissionKind.camera => PrismIcons.camera,
    SitePermissionKind.microphone => PrismIcons.microphone,
    SitePermissionKind.location => PrismIcons.location,
    SitePermissionKind.notifications => PrismIcons.notifications,
    SitePermissionKind.popups => PrismIcons.popups,
  };

  static String nameOf(AppLocalizations l, SitePermissionKind k) => switch (k) {
    SitePermissionKind.camera => l.permCamera,
    SitePermissionKind.microphone => l.permMicrophone,
    SitePermissionKind.location => l.permLocation,
    SitePermissionKind.notifications => l.permNotifications,
    SitePermissionKind.popups => l.permPopups,
  };

  static String decisionOf(AppLocalizations l, PermissionDecision d) =>
      switch (d) {
        PermissionDecision.ask => l.decisionAsk,
        PermissionDecision.allow => l.decisionAllow,
        PermissionDecision.block => l.decisionBlock,
      };

  Future<void> _edit(SitePermissionKind k) async {
    final l = AppLocalizations.of(context);
    await showPrismSheet<void>(
      context,
      title: nameOf(l, k),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: const EdgeInsets.only(bottom: PrismSpace.md),
          child: PrismSegmented<PermissionDecision>(
            segments: [
              for (final d in PermissionDecision.values)
                PrismSegment(value: d, label: decisionOf(l, d)),
            ],
            selected: _defaults[k]!,
            onChanged: (d) {
              setState(() => _defaults[k] = d);
              set(() {});
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sites = ref.watch(sitePermissionsProvider);
    final byHost = <String, List<SitePermission>>{};
    for (final p in sites) {
      (byHost[p.host] ??= []).add(p);
    }
    return PrismPage(
      title: l.permissionsTitle,
      children: [
        PrismSection(
          title: l.permDefaults,
          children: [
            for (final k in SitePermissionKind.values)
              PrismTile(
                icon: iconOf(k),
                title: nameOf(l, k),
                subtitle: decisionOf(l, _defaults[k]!),
                chevron: true,
                onTap: () => _edit(k),
              ),
          ],
        ),
        PrismSection(
          title: l.permSites,
          children: [
            for (final MapEntry(key: host, value: perms) in byHost.entries)
              PrismTile(
                leading: LetterFavicon(label: host, host: host, size: 40),
                title: host,
                subtitle: perms
                    .map(
                      (p) =>
                          '${nameOf(l, p.kind)}: ${decisionOf(l, p.decision)}',
                    )
                    .join(' · '),
                chevron: true,
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}
