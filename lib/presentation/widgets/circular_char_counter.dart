import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

class CircularCharCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const CircularCharCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = maxLength - currentLength;
    final progress = maxLength > 0
        ? (currentLength / maxLength).clamp(0.0, 1.0)
        : 0.0;
    final isOver = remaining < 0;
    final isWarning = remaining >= 0 && remaining <= 20;

    Color progressColor;
    if (isOver) {
      progressColor = AppColors.warning;
    } else if (isWarning) {
      progressColor = AppColors.warningYellow;
    } else {
      progressColor = AppColors.accent;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppDimens.counterSize,
          height: AppDimens.counterSize,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: progress,
              progressColor: progressColor,
              trackColor: trackColor,
              strokeWidth: AppDimens.counterStrokeWidth,
            ),
            child: isOver || isWarning
                ? Center(
                    child: Text(
                      '$remaining',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
