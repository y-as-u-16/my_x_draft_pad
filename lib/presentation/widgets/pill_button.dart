import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

enum PillButtonStyle { filled, outline }

class PillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final PillButtonStyle style;
  final double? height;
  final EdgeInsets? padding;

  const PillButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style = PillButtonStyle.filled,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (style == PillButtonStyle.outline) {
      return SizedBox(
        height: height ?? AppDimens.pillButtonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor),
            shape: const StadiumBorder(),
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingMedium,
                ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height ?? AppDimens.pillButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
        ),
        child: child,
      ),
    );
  }
}
