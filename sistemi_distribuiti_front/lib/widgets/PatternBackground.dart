import 'package:flutter/material.dart';
import 'dart:math';

class PatternBackground extends StatelessWidget {
  final Widget child;

  const PatternBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sfondo a pattern
        Positioned.fill(
          child: CustomPaint(
            painter: PatternPainter(),
          ),
        ),
        // Contenuto sovrapposto
        child,
      ],
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Background gradient
    final backgroundGradient = LinearGradient(
      colors: [Color(0xFF009FFD), Color(0xFF2A2A72)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Repeating linear gradients
    final repeatingGradient1 = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.transparent,
        Color(0x26FFFFFF),
        Color(0x26FFFFFF)
      ],
      stops: [0.0, 0.5, 0.5, 1.0],
      tileMode: TileMode.repeated,
      transform: GradientRotation(45 * pi / 180),
    );

    final repeatingGradient2 = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.transparent,
        Color(0x26FFFFFF),
        Color(0x26FFFFFF)
      ],
      stops: [0.0, 0.5, 0.5, 1.0],
      tileMode: TileMode.repeated,
      transform: GradientRotation(-45 * pi / 180),
    );

    final backgroundPaint = Paint()..shader = backgroundGradient.createShader(rect);
    final repeatingPaint1 = Paint()..shader = repeatingGradient1.createShader(rect);
    final repeatingPaint2 = Paint()..shader = repeatingGradient2.createShader(rect);

    // Draw gradients
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRect(rect, repeatingPaint1);
    canvas.drawRect(rect, repeatingPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
