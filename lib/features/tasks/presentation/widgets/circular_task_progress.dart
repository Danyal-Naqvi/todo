import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CircularTaskProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final double size;
  final double strokeWidth;

  const CircularTaskProgress({
    super.key,
    required this.progress,
    this.progressColor = AppColors.primary,
    this.size = 54,
    this.strokeWidth = 4.5,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress.clamp(0.0, 1.0) * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              progressColor: progressColor,
              backgroundColor: const Color(0xFFEAECEF),
              strokeWidth: strokeWidth,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw active arc starting from top (-pi / 2)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
