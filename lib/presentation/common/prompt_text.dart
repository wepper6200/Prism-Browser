import 'package:material_ui/material_ui.dart';

import '../../core/design/components/prism_button.dart';
import '../../core/design/components/prism_sheet.dart';
import '../../core/design/tokens.dart';

/// One-field sheet (folder or group name). Null when cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  String initial = '',
}) => showPrismSheet<String>(
  context,
  title: title,
  builder: (ctx) => _PromptText(label: label, action: action, initial: initial),
);

class _PromptText extends StatefulWidget {
  const _PromptText({
    required this.label,
    required this.action,
    required this.initial,
  });

  final String label;
  final String action;
  final String initial;

  @override
  State<_PromptText> createState() => _PromptTextState();
}

class _PromptTextState extends State<_PromptText> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: _c,
        autofocus: true,
        maxLength: 60,
        decoration: InputDecoration(labelText: widget.label),
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      const SizedBox(height: PrismSpace.md),
      PrismButton(
        label: widget.action,
        expand: true,
        onPressed: () => Navigator.of(context).pop(_c.text),
      ),
    ],
  );
}
