import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_controls.dart';
import '../../core/design/components/prism_list.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/prism_page.dart';
import '../common/prompt_text.dart';
import '../common/site_visuals.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _q = '';

  /// Open folder; null = the top level (folders + unsorted).
  String? _folder;

  BookmarkActions get _actions => ref.read(bookmarkActionsProvider);

  void _open(Bookmark b) {
    ref.read(browserActionsProvider).open(b.url).ignore();
    context.go('/');
  }

  Future<void> _newFolder() async {
    final l = AppLocalizations.of(context);
    final name = await promptText(
      context,
      title: l.bookmarksNewFolder,
      label: l.bookmarksFolderName,
      action: l.actionSave,
    );
    if (name != null && name.trim().isNotEmpty) {
      await _actions.addFolder(name);
    }
  }

  Future<void> _folderMenu(BookmarkFolder f) async {
    final l = AppLocalizations.of(context);
    final choice = await showPrismSheet<String>(
      context,
      title: f.name,
      builder: (ctx) => PrismSection(
        children: [
          PrismTile(
            icon: PrismIcons.appearance,
            title: l.actionRename,
            onTap: () => Navigator.of(ctx).pop('rename'),
          ),
          PrismTile(
            icon: PrismIcons.delete,
            tone: PrismBadgeTone.danger,
            title: l.bookmarksDeleteFolder,
            subtitle: l.bookmarksDeleteFolderSub,
            onTap: () => Navigator.of(ctx).pop('delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'rename') {
      final name = await promptText(
        context,
        title: l.actionRename,
        label: l.bookmarksFolderName,
        initial: f.name,
        action: l.actionSave,
      );
      if (name != null && name.trim().isNotEmpty) {
        await _actions.renameFolder(f.id, name);
      }
    } else if (choice == 'delete') {
      await _actions.deleteFolder(f.id);
      if (mounted && _folder == f.id) setState(() => _folder = null);
    }
  }

  Future<void> _edit(Bookmark b) async {
    final updated = await showPrismSheet<Bookmark?>(
      context,
      title: AppLocalizations.of(context).bookmarksEdit,
      builder: (ctx) => _EditBookmark(
        bookmark: b,
        folders: ref.read(bookmarkFoldersProvider),
      ),
    );
    if (updated == null) return;
    if (updated.id.isEmpty) {
      await _actions.delete(b.id);
    } else {
      await _actions.update(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final folders = ref.watch(bookmarkFoldersProvider);
    final all = ref.watch(bookmarksProvider);
    final folder = folders.where((f) => f.id == _folder).firstOrNull;
    final q = _q.trim().toLowerCase();
    bool hit(String s) => s.toLowerCase().contains(q);
    final shown = q.isNotEmpty
        ? all.where((b) => hit(b.title) || hit(b.url)).toList()
        : all.where((b) => b.folderId == folder?.id).toList();

    Widget tile(Bookmark b) => PrismTile(
      key: ValueKey(b.id),
      leading: LetterFavicon(label: b.title, host: hostOf(b.url), size: 40),
      title: b.title,
      subtitle: hostOf(b.url),
      onTap: () => _open(b),
      trailing: PrismIconButton(
        icon: PrismIcons.more,
        tooltip: l.bookmarksEdit,
        onPressed: () => _edit(b),
      ),
    );

    return PopScope(
      // Back leaves a folder before leaving the screen.
      canPop: folder == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _folder = null);
      },
      child: PrismPage(
        title: folder?.name ?? l.bookmarksTitle,
        actions: [
          if (folder == null)
            PrismIconButton(
              icon: PrismIcons.folder,
              tooltip: l.bookmarksNewFolder,
              onPressed: _newFolder,
            )
          else
            PrismIconButton(
              icon: PrismIcons.more,
              tooltip: l.actionMore,
              onPressed: () => _folderMenu(folder),
            ),
        ],
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
          else if (q.isNotEmpty) ...[
            if (shown.isEmpty)
              PrismEmptyState(
                icon: PrismIcons.search,
                title: l.emptySearchTitle,
                body: l.emptySearchBody,
              )
            else
              PrismSection(children: [for (final b in shown) tile(b)]),
          ] else ...[
            if (folder == null && folders.isNotEmpty)
              PrismSection(
                title: l.bookmarksFolders,
                children: [
                  for (final f in folders)
                    PrismTile(
                      key: ValueKey(f.id),
                      icon: PrismIcons.folderSimple,
                      title: f.name,
                      subtitle: l.bookmarksInFolder(
                        all.where((b) => b.folderId == f.id).length,
                      ),
                      chevron: true,
                      onTap: () => setState(() => _folder = f.id),
                    ),
                ],
              ),
            if (shown.isNotEmpty)
              PrismSection(
                title: folder == null ? l.bookmarksUnsorted : null,
                children: [for (final b in shown) tile(b)],
              )
            else if (folder != null)
              PrismEmptyState(
                icon: PrismIcons.folderOpen,
                title: l.bookmarksFolderEmpty,
                body: l.emptyBookmarksBody,
              ),
          ],
        ],
      ),
    );
  }
}

/// Title + folder; returns the edited bookmark, a bookmark with an empty
/// id for "delete", or null when cancelled.
class _EditBookmark extends StatefulWidget {
  const _EditBookmark({required this.bookmark, required this.folders});

  final Bookmark bookmark;
  final List<BookmarkFolder> folders;

  @override
  State<_EditBookmark> createState() => _EditBookmarkState();
}

class _EditBookmarkState extends State<_EditBookmark> {
  late final _title = TextEditingController(text: widget.bookmark.title);
  late String? _folder = widget.bookmark.folderId;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = widget.bookmark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _title,
          decoration: InputDecoration(labelText: l.bookmarksFieldTitle),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: PrismSpace.lg),
        PrismSection(
          title: l.bookmarksFieldFolder,
          children: [
            for (final (id, name) in [
              (null, l.bookmarksUnsorted),
              for (final f in widget.folders) (f.id, f.name),
            ])
              Semantics(
                selected: _folder == id,
                inMutuallyExclusiveGroup: true,
                child: PrismTile(
                  icon: id == null
                      ? PrismIcons.bookmark
                      : PrismIcons.folderSimple,
                  tone: PrismBadgeTone.neutral,
                  title: name,
                  onTap: () => setState(() => _folder = id),
                  trailing: _folder == id
                      ? const Icon(PrismIcons.check, size: 22)
                      : const SizedBox(width: 22),
                ),
              ),
          ],
        ),
        PrismButton(
          label: l.actionSave,
          expand: true,
          onPressed: () => Navigator.of(context).pop(
            Bookmark(
              id: b.id,
              title: _title.text.trim().isEmpty ? b.url : _title.text.trim(),
              url: b.url,
              folderId: _folder,
            ),
          ),
        ),
        const SizedBox(height: PrismSpace.sm),
        PrismButton(
          label: l.actionDelete,
          icon: PrismIcons.delete,
          variant: PrismButtonVariant.danger,
          expand: true,
          onPressed: () =>
              Navigator.of(context)
                  .pop(Bookmark(id: '', title: b.title, url: b.url)),
        ),
      ],
    );
  }
}
