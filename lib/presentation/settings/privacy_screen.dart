import 'package:flutter/foundation.dart';
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

/// Privacy & security. Platform limitations are shown on the affected
/// rows ("limitedLabel"); nothing pretends to work where the engine can't.
/// Stage 2: values live in memory; stage 5 wires and persists them.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(privacyProvider);
    final c = ref.read(privacyProvider.notifier);
    final android = defaultTargetPlatform == TargetPlatform.android;

    return PrismPage(
      title: l.settingsPrivacy,
      children: [
        const ProfilePicker(),
        PrismSection(
          title: l.secBlocking,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.eyeSlash,
              title: l.pBlockTrackers,
              subtitle: l.pBlockTrackersSub,
              value: p.blockTrackers,
              onChanged: (v) => c.update((s) => s.copyWith(blockTrackers: v)),
            ),
            PrismSwitchTile(
              icon: PrismIcons.block,
              title: l.pBlockAds,
              subtitle: l.pBlockAdsSub,
              value: p.blockAds,
              onChanged: (v) => c.update((s) => s.copyWith(blockAds: v)),
            ),
          ],
        ),
        PrismSection(
          title: l.secConnection,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.lock,
              tone: PrismBadgeTone.secure,
              title: l.pHttpsOnly,
              subtitle: l.pHttpsOnlySub,
              value: p.httpsOnly,
              onChanged: (v) => c.update((s) => s.copyWith(httpsOnly: v)),
            ),
            PrismSwitchTile(
              icon: PrismIcons.globeWorld,
              title: l.pDoh,
              subtitle: l.pDohSub,
              value: !android && p.dnsOverHttps,
              // Android WebView has no per-app DNS: honest, disabled.
              onChanged: android
                  ? null
                  : (v) => c.update((s) => s.copyWith(dnsOverHttps: v)),
              limitedLabel: android ? l.limitedAndroidDoh : null,
            ),
          ],
        ),
        PrismSection(
          title: l.secCookies,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.cookie,
              title: l.pThirdParty,
              value: p.blockThirdPartyCookies,
              onChanged: (v) =>
                  c.update((s) => s.copyWith(blockThirdPartyCookies: v)),
            ),
            PrismSwitchTile(
              icon: PrismIcons.eraser,
              title: l.pClearOnExit,
              subtitle: l.pClearOnExitSub,
              value: p.clearOnExit,
              onChanged: (v) => c.update((s) => s.copyWith(clearOnExit: v)),
            ),
            PrismSwitchTile(
              icon: PrismIcons.link,
              title: l.pStripParams,
              subtitle: l.pStripParamsSub,
              value: p.stripTrackingParams,
              onChanged: (v) =>
                  c.update((s) => s.copyWith(stripTrackingParams: v)),
            ),
          ],
        ),
        PrismSection(
          title: l.secFingerprint,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.hand,
              title: l.pGpc,
              subtitle: l.pGpcSub,
              value: p.globalPrivacyControl,
              onChanged: (v) =>
                  c.update((s) => s.copyWith(globalPrivacyControl: v)),
            ),
            PrismSwitchTile(
              icon: PrismIcons.fingerprintScan,
              title: l.pFingerprint,
              value: p.antiFingerprinting,
              onChanged: (v) =>
                  c.update((s) => s.copyWith(antiFingerprinting: v)),
              limitedLabel: l.limitedPartial,
            ),
            PrismSwitchTile(
              icon: PrismIcons.wifi,
              title: l.pWebRtc,
              value: p.blockWebRtcLeak,
              onChanged: (v) => c.update((s) => s.copyWith(blockWebRtcLeak: v)),
              limitedLabel: android ? l.limitedPartial : null,
            ),
          ],
        ),
        PrismSection(
          title: l.secApp,
          footer: l.noTelemetry,
          children: [
            PrismSwitchTile(
              icon: PrismIcons.fingerprint,
              title: l.pAppLock,
              subtitle: l.pAppLockSub,
              value: p.appLock,
              onChanged: (v) => c.update((s) => s.copyWith(appLock: v)),
            ),
          ],
        ),
        PrismButton(
          label: l.pForgetAll,
          icon: PrismIcons.broom,
          variant: PrismButtonVariant.danger,
          expand: true,
          onPressed: () {},
        ),
        const SizedBox(height: PrismSpace.sm),
        Text(
          l.pForgetAllSub,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Standard / Strict / Custom profile cards (also used by onboarding).
class ProfilePicker extends ConsumerWidget {
  const ProfilePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(privacyProvider);
    final c = ref.read(privacyProvider.notifier);
    return PrismSection(
      title: l.privacyProfile,
      children: [
        for (final (profile, icon, title, desc) in [
          (
            PrivacyProfile.standard,
            PrismIcons.shield,
            l.profileStandard,
            l.profileStandardDesc,
          ),
          (
            PrivacyProfile.strict,
            PrismIcons.lockKey,
            l.profileStrict,
            l.profileStrictDesc,
          ),
          (
            PrivacyProfile.custom,
            PrismIcons.sliders,
            l.profileCustom,
            l.profileCustomDesc,
          ),
        ])
          Semantics(
            selected: p.profile == profile,
            inMutuallyExclusiveGroup: true,
            child: PrismTile(
              icon: icon,
              tone: profile == PrivacyProfile.strict
                  ? PrismBadgeTone.secure
                  : PrismBadgeTone.accent,
              title: title,
              subtitle: desc,
              onTap: () => c.setProfile(profile),
              trailing: p.profile == profile
                  ? const Icon(PrismIcons.success, size: 22)
                  : const SizedBox(width: 22),
            ),
          ),
      ],
    );
  }
}
