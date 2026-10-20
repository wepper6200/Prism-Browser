import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/prism_icons.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/site_visuals.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final folders = ref.watch(bookmarkFoldersProvider);
    final all = ref.watch(bookmarksProvider);
    bool hit(String s) => s.toLowerCase().contains(_q.toLowerCase());
    final found = all.where((b) => hit(b.title) || hit(b.url)).toList();
    return PrismPage(
      title: l.bookmarksTitle,
      header: PrismSearchField(
        hint: l.bookmarksSearch,
        onChanged: (v) => setState(() => _q = v),
      ),
      children: [
        if (all.isEmpty && folders.isEmpty)
          PrismEmptyState(
            icon: PrismIcons.bookmark,
            title: l.emptyBookmarksTitle,
            body: l.emptyBookmarksBody,
          )
        else ...[
          if (_q.isEmpty)
            PrismSection(
              title: l.bookmarksFolders,
              children: [
                for (final f in folders)
                  PrismTile(
                    icon: PrismIcons.folderSimple,
                    title: f.name,
                    subtitle: l.bookmarksInFolder(
                      all.where((b) => b.folderId == f.id).length,
                    ),
                    chevron: true,
                    onTap: () {},
                  ),
              ],
            ),
          PrismSection(
            title: _q.isEmpty ? l.bookmarksUnsorted : null,
            children: [
              for (final b
                  in _q.isEmpty ? all.where((b) => b.folderId == null) : found)
                PrismTile(
                  leading: LetterFavicon(
                    label: b.title,
                    host: hostOf(b.url),
                    size: 40,
                  ),
                  title: b.title,
                  subtitle: hostOf(b.url),
                  onTap: () {},
                ),
            ],
          ),
        ],
      ],
    );
  }
}
