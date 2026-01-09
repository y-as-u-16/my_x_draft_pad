import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/neumorphic_decorations.dart';

class NeumorphicTextFieldShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const NeumorphicTextFieldShell({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.all(AppDimens.paddingMedium),
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: NeumorphicDecorations.concave(
        isDark: isDark,
        borderRadius: AppDimens.radiusMedium,
      ),
      child: child,
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicTextFieldShell(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        autofocus: autofocus,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
