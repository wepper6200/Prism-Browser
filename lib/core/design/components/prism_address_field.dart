import 'package:flutter/widgets.dart';

import '../prism_design.dart';

enum PrismSecurity { secure, insecure, internal }

/// The omnibox "pill" in its resting state. Stage 2 adds the focused/editing
/// state that morphs into the suggestions panel.
class PrismAddressField extends StatelessWidget {
  const PrismAddressField({
    super.key,
    required this.text,
    required this.hint,
    this.security = PrismSecurity.internal,
    this.securityLabel,
    this.onTap,
    this.trailing,
  });

  /// Display text (host or query). Empty shows [hint].
  final String text;
  final String hint;
  final PrismSecurity security;

  /// Accessible description of [security] ("Secure connection").
  final String? securityLabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) =>
      PrismDesign.of(context).buildAddressField(context, this);
}
