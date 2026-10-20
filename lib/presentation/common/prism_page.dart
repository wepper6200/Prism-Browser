import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_toolbar.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';

/// Scaffold for secondary screens (settings, library). Content scrolls
/// under the toolbar: under glass it is refracted, under Material's docked
/// bar it is simply covered.
class PrismPage extends StatelessWidget {
  const PrismPage({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.header,
    this.maxWidth = 720,
  });

  final String title;
  final List<Widget> children;
  final List<Widget> actions;

  /// Pinned under the toolbar (search field, filter chips).
  final Widget? header;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: PrismBackground()),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  PrismSpace.lg,
                  top + 84,
                  PrismSpace.lg,
                  bottom + PrismSpace.xxl,
                ),
                children: [
                  if (header != null) ...[
                    header!,
                    const SizedBox(height: PrismSpace.lg),
                  ],
                  ...children,
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PrismToolbar(
              leading: [
                PrismIconButton(
                  icon: PrismIcons.back,
                  tooltip: l.actionBack,
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ],
              middle: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PrismSpace.xs),
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              trailing: actions,
            ),
          ),
        ],
      ),
    );
  }
}
