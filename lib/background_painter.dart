import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundPainter extends CustomPainter {
  final Color color;

  BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42); // 使用固定种子以保持一致性

    for (int i = 0; i < 50; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 20 + 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    for (int i = 0; i < 30; i++) {
      double x1 = random.nextDouble() * size.width;
      double y1 = random.nextDouble() * size.height;
      double x2 = x1 + random.nextDouble() * 100 - 50;
      double y2 = y1 + random.nextDouble() * 100 - 50;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
