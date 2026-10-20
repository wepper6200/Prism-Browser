import 'package:material_ui/material_ui.dart';

import '../../core/design/components/prism_button.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';

/// Panels the browser screen can show over the page.
enum BrowserPanel {
  none,
  omnibox,
  menu,
  privacy,
  find;

  static BrowserPanel fromName(String? name) => BrowserPanel.values.firstWhere(
    (p) => p.name == name,
    orElse: () => BrowserPanel.none,
  );
}

/// Tabs button with the open-tab count (accessible name includes it).
class TabsCountButton extends StatelessWidget {
  const TabsCountButton({super.key, required this.count, this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        PrismIconButton(
          icon: PrismIcons.tabs,
          tooltip: '${l.actionTabs}. ${l.tabsOpen(count)}',
          onPressed: onPressed,
        ),
        IgnorePointer(
          child: Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.canvas,
              border: Border.all(color: t.onSurface, width: 1.6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              count > 99 ? '∞' : '$count',
              style: TextStyle(
                fontFamily: PrismType.family,
                fontSize: count > 9 ? 9 : 11,
                fontWeight: FontWeight.w700,
                color: t.onSurface,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shield chip inside the address field: blocked count, opens the privacy
/// sheet. Green shield + number + accessible label (never color alone).
class ShieldChip extends StatelessWidget {
  const ShieldChip({super.key, required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    return Tooltip(
      message: l.shieldButton(count),
      child: Semantics(
        button: true,
        label: l.shieldButton(count),
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            height: PrismSpace.touch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PrismIcons.shield, size: 18, color: t.secure),
                  if (count > 0) ...[
                    const SizedBox(width: 3),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: t.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
