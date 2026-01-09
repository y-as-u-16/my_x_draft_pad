import 'package:flutter/material.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/neumorphic_decorations.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppDimens.radiusMedium,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: NeumorphicDecorations.raised(
        isDark: isDark,
        borderRadius: borderRadius,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}
