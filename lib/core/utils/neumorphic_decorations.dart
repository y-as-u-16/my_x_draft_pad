import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class NeumorphicDecorations {
  NeumorphicDecorations._();

  static BoxDecoration raised({
    required bool isDark,
    double borderRadius = AppDimens.radiusMedium,
    Color? color,
  }) {
    final bgColor =
        color ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final shadowTop = isDark
        ? AppColors.shadowDarkTop
        : AppColors.shadowLightTop;
    final shadowBottom = isDark
        ? AppColors.shadowDarkBottom
        : AppColors.shadowLightBottom;

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowTop,
          offset: const Offset(
            -AppDimens.shadowOffset,
            -AppDimens.shadowOffset,
          ),
          blurRadius: AppDimens.shadowBlur,
        ),
        BoxShadow(
          color: shadowBottom,
          offset: const Offset(AppDimens.shadowOffset, AppDimens.shadowOffset),
          blurRadius: AppDimens.shadowBlur,
        ),
      ],
    );
  }

  static BoxDecoration pressed({
    required bool isDark,
    double borderRadius = AppDimens.radiusMedium,
    Color? color,
  }) {
    final bgColor =
        color ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final shadowTop = isDark
        ? AppColors.shadowDarkTop
        : AppColors.shadowLightTop;
    final shadowBottom = isDark
        ? AppColors.shadowDarkBottom
        : AppColors.shadowLightBottom;

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowBottom,
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: shadowTop,
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ],
    );
  }

  static BoxDecoration flat({
    required bool isDark,
    double borderRadius = AppDimens.radiusMedium,
    Color? color,
  }) {
    final bgColor =
        color ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration concave({
    required bool isDark,
    double borderRadius = AppDimens.radiusMedium,
    Color? color,
  }) {
    final bgColor =
        color ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final shadowTop = isDark
        ? AppColors.shadowDarkTop
        : AppColors.shadowLightTop;
    final shadowBottom = isDark
        ? AppColors.shadowDarkBottom
        : AppColors.shadowLightBottom;

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [shadowBottom, bgColor, bgColor, shadowTop],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }
}
