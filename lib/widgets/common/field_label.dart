import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.uppercase = true, this.trailing});

  final String text;
  final bool uppercase;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          uppercase ? text.toUpperCase() : text,
          style: uppercase ? AppTextStyles.label : AppTextStyles.fieldLabel,
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}