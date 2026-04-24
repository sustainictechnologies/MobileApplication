import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Water drop with ripple and leaf — "Water Saved"
class WaterSavedIcon extends StatelessWidget {
  const WaterSavedIcon({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: const _WaterDropPainter());
}

/// CO₂ cloud with arrows and leaf — "Carbon Emission Reduced"
class Co2ReducedIcon extends StatelessWidget {
  const Co2ReducedIcon({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: const _Co2CloudPainter());
}

/// Plastic bottle with no-entry symbol and leaf — "Bottles Saved"
class BottlesSavedIcon extends StatelessWidget {
  const BottlesSavedIcon({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: const _BottlePainter());
}

/// Green medal with gold ribbon — "Eco Points"
class EcoPointsIcon extends StatelessWidget {
  const EcoPointsIcon({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: const _MedalPainter());
}

// ─────────────────────────────────────────────────────────────────────────────
// Water drop painter
// ─────────────────────────────────────────────────────────────────────────────

class _WaterDropPainter extends CustomPainter {
  const _WaterDropPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final r  = s.width * 0.30;

    // Drop body
    final path = Path()
      ..moveTo(cx, s.height * 0.06)
      ..cubicTo(cx + r * 1.65, s.height * 0.40, cx + r, s.height * 0.74, cx, s.height * 0.83)
      ..cubicTo(cx - r, s.height * 0.74, cx - r * 1.65, s.height * 0.40, cx, s.height * 0.06);

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // White highlight glint
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.28, s.height * 0.28),
        width: r * 0.48,
        height: r * 0.72,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );

    // Ripple arcs
    final ripple = Paint()
      ..color = const Color(0xFF29B6F6).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 1; i <= 2; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, s.height * 0.91),
          width: r * (1.0 + i * 0.85),
          height: r * (0.22 + i * 0.10),
        ),
        ripple,
      );
    }

    // Leaf bottom-right
    _leaf(canvas, Offset(cx + r * 0.58, s.height * 0.73), r * 0.34);
  }

  void _leaf(Canvas canvas, Offset c, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx + r, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - r, c.dy, c.dx, c.dy - r),
      Paint()..color = const Color(0xFF4CAF50),
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaterDropPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CO₂ cloud painter
// ─────────────────────────────────────────────────────────────────────────────

class _Co2CloudPainter extends CustomPainter {
  const _Co2CloudPainter();

  static const _green      = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFF4CAF50);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;

    // Cloud stroke
    canvas.drawPath(
      _cloudPath(s),
      Paint()
        ..color = _lightGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * 0.065
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // CO₂ text inside cloud
    final tp = TextPainter(
      text: TextSpan(
        style: TextStyle(
          color: _green,
          fontSize: s.width * 0.215,
          fontWeight: FontWeight.w900,
        ),
        children: const [
          TextSpan(text: 'CO'),
          TextSpan(
            text: '₂',
            style: TextStyle(fontSize: null),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, s.height * 0.13));

    // Two downward arrows
    final ap = Paint()
      ..color = _green
      ..strokeWidth = s.width * 0.058
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final dx in [-0.15, 0.15]) {
      final ax  = cx + s.width * dx;
      final top = s.height * 0.63;
      final bot = s.height * 0.84;
      final hw  = s.width * 0.085;
      canvas.drawLine(Offset(ax, top), Offset(ax, bot), ap);
      canvas.drawPath(
        Path()
          ..moveTo(ax - hw, bot - hw)
          ..lineTo(ax, bot)
          ..lineTo(ax + hw, bot - hw),
        ap,
      );
    }

    // Leaf right of cloud
    _leaf(canvas, Offset(s.width * 0.84, s.height * 0.37), s.width * 0.11);
  }

  Path _cloudPath(Size s) {
    final cx = s.width / 2;
    return Path()
      ..moveTo(s.width * 0.13, s.height * 0.54)
      ..lineTo(s.width * 0.87, s.height * 0.54)
      ..arcToPoint(Offset(s.width * 0.87, s.height * 0.32),
          radius: Radius.circular(s.width * 0.15), clockwise: false)
      ..arcToPoint(Offset(cx + s.width * 0.10, s.height * 0.17),
          radius: Radius.circular(s.width * 0.14), clockwise: false)
      ..arcToPoint(Offset(cx - s.width * 0.10, s.height * 0.17),
          radius: Radius.circular(s.width * 0.16), clockwise: false)
      ..arcToPoint(Offset(s.width * 0.13, s.height * 0.32),
          radius: Radius.circular(s.width * 0.14), clockwise: false)
      ..arcToPoint(Offset(s.width * 0.13, s.height * 0.54),
          radius: Radius.circular(s.width * 0.13), clockwise: false);
  }

  void _leaf(Canvas canvas, Offset c, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx + r, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - r, c.dy, c.dx, c.dy - r),
      Paint()..color = _lightGreen,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Co2CloudPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottle painter
// ─────────────────────────────────────────────────────────────────────────────

class _BottlePainter extends CustomPainter {
  const _BottlePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx   = s.width  * 0.42;
    final bw   = s.width  * 0.30;
    final bTop = s.height * 0.28;
    final bBot = s.height * 0.88;
    final nw   = bw * 0.52;

    // Cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, s.height * 0.08), width: nw * 0.85, height: s.height * 0.09),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1565C0),
    );

    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, bTop - s.height * 0.07), width: nw, height: s.height * 0.14),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // Bottle body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - bw / 2, bTop, cx + bw / 2, bBot),
        const Radius.circular(7),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE1F5FE), Color(0xFF81D4FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // Water fill inside
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - bw / 2 + 3, bTop + (bBot - bTop) * 0.38, cx + bw / 2 - 3, bBot - 4),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF29B6F6).withValues(alpha: 0.38),
    );

    // No-entry circle
    final nr = s.width * 0.21;
    final nc = Offset(s.width * 0.63, s.height * 0.50);
    canvas.drawCircle(nc, nr + 2.5, Paint()..color = Colors.white);
    final noPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.068
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(nc, nr, noPaint);
    final barR = nr * 0.66;
    canvas.drawLine(
      nc + Offset(-barR, barR),
      nc + Offset(barR, -barR),
      noPaint,
    );

    // Leaf bottom-right
    _leaf(canvas, Offset(s.width * 0.83, s.height * 0.80), s.width * 0.11);
  }

  void _leaf(Canvas canvas, Offset c, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx + r, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - r, c.dy, c.dx, c.dy - r),
      Paint()..color = const Color(0xFF4CAF50),
    );
  }

  @override
  bool shouldRepaint(_BottlePainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Medal painter
// ─────────────────────────────────────────────────────────────────────────────

class _MedalPainter extends CustomPainter {
  const _MedalPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width  / 2;
    final r  = s.width  * 0.35;
    final cy = s.height * 0.40;

    // Gold ribbons
    final goldPaint = Paint()..color = const Color(0xFFFFA000);
    canvas.drawPath(
      Path()
        ..moveTo(cx - r * 0.28, cy + r * 0.72)
        ..lineTo(cx - r * 0.90, s.height * 0.99)
        ..lineTo(cx,            s.height * 0.99)
        ..lineTo(cx + r * 0.12, cy + r * 0.72)
        ..close(),
      goldPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - r * 0.12, cy + r * 0.72)
        ..lineTo(cx,            s.height * 0.99)
        ..lineTo(cx + r * 0.90, s.height * 0.99)
        ..lineTo(cx + r * 0.28, cy + r * 0.72)
        ..close(),
      goldPaint,
    );
    // Ribbon centre highlight
    canvas.drawRect(
      Rect.fromLTWH(cx - r * 0.10, cy + r * 0.72, r * 0.20, s.height * 0.99 - cy - r * 0.72),
      Paint()..color = const Color(0xFFFFCA28),
    );

    // Medal shadow
    canvas.drawCircle(
      Offset(cx, cy + 3),
      r,
      Paint()
        ..color = const Color(0xFF1B5E20).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Medal disc
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Disc rim highlight
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * 0.045,
    );

    // Leaf inside (rotated)
    final lr = r * 0.50;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 4);
    canvas.drawPath(
      Path()
        ..moveTo(0, -lr)
        ..quadraticBezierTo(lr, 0, 0, lr)
        ..quadraticBezierTo(-lr, 0, 0, -lr),
      Paint()..color = Colors.white,
    );
    canvas.drawLine(
      Offset(0, -lr), Offset(0, lr),
      Paint()
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.55)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MedalPainter _) => false;
}
