import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/neumorphic_decorations.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color? color;
  final bool isAccent;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = AppDimens.radiusMedium,
    this.padding,
    this.color,
    this.isAccent = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.isAccent
        ? AppColors.accent
        : widget.color ??
              (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingLarge,
              vertical: AppDimens.paddingMedium,
            ),
        decoration: _isPressed
            ? NeumorphicDecorations.pressed(
                isDark: isDark,
                borderRadius: widget.borderRadius,
                color: bgColor,
              )
            : NeumorphicDecorations.raised(
                isDark: isDark,
                borderRadius: widget.borderRadius,
                color: bgColor,
              ),
        child: widget.child,
      ),
    );
  }
}
