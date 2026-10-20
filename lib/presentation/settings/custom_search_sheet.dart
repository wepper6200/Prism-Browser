import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/browser/browser_providers.dart';
import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/prism_icons.dart';
import '../../core/design/tokens.dart';
import '../../domain/browser/models.dart';
import '../../l10n/gen/app_localizations.dart';

/// Opens the "Custom search engine" form; saving selects the engine.
Future<void> showCustomSearchSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showPrismSheet<void>(
    context,
    title: l.customSearchTitle,
    builder: (_) => const _CustomSearchForm(),
  );
}

class _CustomSearchForm extends ConsumerStatefulWidget {
  const _CustomSearchForm();

  @override
  ConsumerState<_CustomSearchForm> createState() => _CustomSearchFormState();
}

class _CustomSearchFormState extends ConsumerState<_CustomSearchForm> {
  late final SearchEngine? _existing = ref.read(customSearchProvider);
  late final _name = TextEditingController(text: _existing?.name ?? '');
  late final _url = TextEditingController(text: _existing?.queryTemplate ?? '');
  CustomTemplateError? _error;
  bool _touched = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  String? _message(AppLocalizations l, CustomTemplateError? e) => switch (e) {
    null => null,
    CustomTemplateError.empty => l.customErrEmpty,
    CustomTemplateError.invalidUrl => l.customErrUrl,
    CustomTemplateError.missingPlaceholder => l.customErrNoPlaceholder,
    CustomTemplateError.tooManyPlaceholders => l.customErrMany,
  };

  void _save() {
    final err = ref
        .read(customSearchProvider.notifier)
        .save(name: _name.text, template: _url.text);
    if (err != null) {
      setState(() {
        _error = err;
        _touched = true;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = PrismTokens.of(context);
    final text = Theme.of(context).textTheme;
    final live = CustomSearchTemplate.validate(_url.text);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.customSearchName,
              hintText: l.customSearchNameHint,
            ),
          ),
          const SizedBox(height: PrismSpace.lg),
          // Validate on blur/submit, not on every keystroke.
          Focus(
            onFocusChange: (has) {
              if (!has && _url.text.isNotEmpty) {
                setState(() {
                  _touched = true;
                  _error = live.error;
                });
              }
            },
            child: TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {
                if (_touched) {
                  _error = CustomSearchTemplate.validate(_url.text).error;
                }
              }),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: '${l.customSearchUrl} *',
                hintText: 'https://searx.be/search?q=%s',
                helperText: l.customSearchUrlHelp,
                errorText: _touched ? _message(l, _error) : null,
              ),
            ),
          ),
          if (live.isValid && live.insecure) ...[
            const SizedBox(height: PrismSpace.sm),
            Row(
              children: [
                Icon(PrismIcons.lockOpen, size: 16, color: t.warning),
                const SizedBox(width: PrismSpace.sm),
                Expanded(
                  child: Text(
                    l.customInsecure,
                    style: text.bodySmall?.copyWith(color: t.warning),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: PrismSpace.xl),
          PrismButton(
            label: l.actionSave,
            icon: PrismIcons.check,
            expand: true,
            onPressed: _save,
          ),
          if (_existing != null) ...[
            const SizedBox(height: PrismSpace.sm),
            PrismButton(
              label: l.actionDelete,
              icon: PrismIcons.delete,
              variant: PrismButtonVariant.danger,
              expand: true,
              onPressed: () {
                ref.read(customSearchProvider.notifier).remove();
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
