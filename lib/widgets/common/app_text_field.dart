import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'field_label.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.labelTrailing,
    this.enabled = true,
    this.autofillHints,
    this.onFieldSubmitted,
    this.uppercaseLabel = true,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Widget? labelTrailing;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  /// Figma uses uppercase labels on Login/New Task, sentence case on Edit Task.
  final bool uppercaseLabel;
  final int? maxLength;
  final int? minLines;
  final int maxLines;

  /// Replaces the default suffix (e.g. a clear button). Ignored for passwords.
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textHint,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.maxLines != 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          widget.label,
          uppercase: widget.uppercaseLabel,
          trailing: widget.labelTrailing,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType ??
              (isMultiline ? TextInputType.multiline : null),
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          maxLength: widget.maxLength,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textAlignVertical: isMultiline ? TextAlignVertical.top : null,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.hint,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            suffixIcon: _buildSuffix(),
            errorStyle: AppTextStyles.error,
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary, 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.5),
          ),
        ),
      ],
    );
  }
}