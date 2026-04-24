import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
//  Sustainic Technologies — Splash Screen
//
//  Animation timeline (total 2 800 ms, then 300 ms hold):
//
//    0 – 600 ms    │ Logo fades in and scales up
//  650 – 1 350 ms  │ Blue  drop falls  top    → second "i"
//  750 – 1 450 ms  │ Green drop rises  bottom → first  "i"
// 1 350 – 1 750 ms │ Second "i" lights up blue   + ripple
// 1 450 – 1 850 ms │ First  "i" lights up green  + ripple
// 1 350 – 2 050 ms │ Blue  ripple expands and fades
// 1 450 – 2 150 ms │ Green ripple expands and fades
//  3 100 ms         → navigate to /onboarding
// ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Master controller – drives every sub-animation ─────────
  late final AnimationController _ctrl;

  // ── Logo appear ────────────────────────────────────────────
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // ── Blue drop  (falls: top → second "i") ──────────────────
  late final Animation<double> _blueDropT;     // travel  0 → 1
  late final Animation<double> _blueDropAlpha; // opacity envelope

  // ── Green drop (rises: bottom → first "i") ────────────────
  late final Animation<double> _greenDropT;
  late final Animation<double> _greenDropAlpha;

  // ── Character glow ─────────────────────────────────────────
  late final Animation<double> _blueGlow;   // second "i" → blue  (0→1)
  late final Animation<double> _greenGlow;  // first  "i" → green (0→1)

  // ── Ripple circles ─────────────────────────────────────────
  late final Animation<double> _blueRipple;
  late final Animation<double> _greenRipple;

  // ── Measured glyph positions ───────────────────────────────
  static const double _kFontSize = 50.0;
  static const String _kWord     = 'Sustainic';
  // Character indices: S=0 u=1 s=2 t=3 a=4 [i]=5 n=6 [i]=7 c=8

  late final double _textW;    // rendered width  of "Sustainic"
  late final double _textH;    // rendered height of "Sustainic"
  late final double _firstIX;  // center-x of first  'i' from text-left
  late final double _secondIX; // center-x of second 'i' from text-left

  static const int _kTotalMs = 2800;

  // ── Brand colours ──────────────────────────────────────────
  static const Color _kBlue  = Color(0xFF0288D1);
  static const Color _kGreen = Color(0xFF2E7D32);

  // ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _measureGlyphPositions();
    _buildAnimations();
    _ctrl.forward();

    // Navigate after animation + short hold
    Future.delayed(const Duration(milliseconds: _kTotalMs + 300), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  /// Use [TextPainter] to find the exact pixel center-x of each 'i'
  /// inside "Sustainic" at the chosen font size, so drops and ripples
  /// land precisely on the correct glyphs.
  void _measureGlyphPositions() {
    final style = GoogleFonts.poppins(
      fontSize: _kFontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    );
    final tp = TextPainter(
      text: TextSpan(text: _kWord, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    _textW = tp.width;
    _textH = tp.height;

    // getOffsetForCaret(offset, Rect.zero) → caret x just before that char
    double cx(int n) =>
        tp.getOffsetForCaret(TextPosition(offset: n), Rect.zero).dx;

    _firstIX  = (cx(5) + cx(6)) / 2; // midpoint of first  'i'  (index 5)
    _secondIX = (cx(7) + cx(8)) / 2; // midpoint of second 'i'  (index 7)
  }

  void _buildAnimations() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kTotalMs),
    );

    final double T = _kTotalMs.toDouble();

    // Convenience: 0→1 tween over [ms0, ms1] with curve [c]
    Animation<double> iv(double ms0, double ms1, Curve c) =>
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(ms0 / T, ms1 / T, curve: c),
          ),
        );

    // ── Logo appear: 0 – 600 ms ──
    _logoFade  = iv(0, 500, Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0, 620 / T, curve: Curves.easeOutBack),
      ),
    );

    // ── Blue drop: 650 – 1 350 ms ──
    _blueDropT = iv(650, 1350, Curves.easeIn);
    _blueDropAlpha = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _ctrl, curve: Interval(650 / T, 1350 / T)),
    );

    // ── Green drop: 750 – 1 450 ms ──
    _greenDropT = iv(750, 1450, Curves.easeIn);
    _greenDropAlpha = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _ctrl, curve: Interval(750 / T, 1450 / T)),
    );

    // ── Highlights ──
    _blueGlow  = iv(1350, 1750, Curves.easeOut); // second 'i' → blue
    _greenGlow = iv(1450, 1850, Curves.easeOut); // first  'i' → green

    // ── Ripples ──
    _blueRipple  = iv(1350, 2050, Curves.easeOut);
    _greenRipple = iv(1450, 2150, Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => _buildFrame(context),
      ),
    );
  }

  Widget _buildFrame(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // ── Compute absolute screen coords for each 'i' ──────────
    // Column layout: "Sustainic" (textH) + 4 px gap + "Technologies" (~22 px)
    const double kTechH = 22.0;
    final double colH   = _textH + 4 + kTechH;

    // Top edge of "Sustainic" text (Column is centred on screen)
    final double sustainicTopY = size.height / 2 - colH / 2;
    // Left edge of "Sustainic" text
    final double textLeft = size.width / 2 - _textW / 2;

    // Screen-absolute X of each 'i' centre
    final double firstIAbsX  = textLeft + _firstIX;
    final double secondIAbsX = textLeft + _secondIX;

    // Tittle (dot) sits ≈ 15 % from top of the glyph bounding box
    final double dotY  = sustainicTopY + _textH * 0.15;
    // Stem base sits ≈ 84 % from top
    final double stemY = sustainicTopY + _textH * 0.84;
    // Glyph vertical centre (ripple origin)
    final double iCentreY = sustainicTopY + _textH * 0.50;

    // ── Interpolated drop Y positions ────────────────────────
    // Blue  drop: starts above screen (−55), ends at dot level
    final double blueY  = _lerp(-55.0, dotY,               _blueDropT.value);
    // Green drop: starts below screen (+55), ends at stem base
    final double greenY = _lerp(size.height + 55.0, stemY, _greenDropT.value);

    return Container(
      // Subtle gradient: blue-tinted top, white centre, green-tinted bottom
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE1F5FE), // soft blue
            Color(0xFFFFFFFF), // white
            Color(0xFFE8F5E9), // soft green
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── Logo (fades + scales in) ─────────────────────
          Center(
            child: Opacity(
              opacity: _logoFade.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: _SustainicLogo(
                  blueGlow: _blueGlow.value,
                  greenGlow: _greenGlow.value,
                  fontSize: _kFontSize,
                ),
              ),
            ),
          ),

          // ── Blue drop (falling, point at top) ───────────
          if (_blueDropAlpha.value > 0.01)
            Positioned(
              left: secondIAbsX - 10, // centre the 20 px-wide shape on 'i'
              top: blueY,
              child: Opacity(
                opacity: _blueDropAlpha.value,
                child: CustomPaint(
                  size: const Size(20, 34),
                  painter: _DropPainter(
                    color: _kBlue,
                    pointAtTop: true, // falling → tail at top
                  ),
                ),
              ),
            ),

          // ── Green drop (rising, point at bottom) ────────
          if (_greenDropAlpha.value > 0.01)
            Positioned(
              left: firstIAbsX - 10, // centre horizontally on 'i'
              // Widget origin is top-left; rising drop has tail at bottom,
              // so subtract full height to keep leading end at greenY.
              top: greenY - 34,
              child: Opacity(
                opacity: _greenDropAlpha.value,
                child: CustomPaint(
                  size: const Size(20, 34),
                  painter: _DropPainter(
                    color: _kGreen,
                    pointAtTop: false, // rising → tail at bottom
                  ),
                ),
              ),
            ),

          // ── Blue ripple ──────────────────────────────────
          if (_blueRipple.value > 0 && _blueRipple.value < 1.0)
            Positioned.fill(
              child: CustomPaint(
                painter: _RipplePainter(
                  center: Offset(secondIAbsX, iCentreY),
                  progress: _blueRipple.value,
                  color: _kBlue,
                ),
              ),
            ),

          // ── Green ripple ─────────────────────────────────
          if (_greenRipple.value > 0 && _greenRipple.value < 1.0)
            Positioned.fill(
              child: CustomPaint(
                painter: _RipplePainter(
                  center: Offset(firstIAbsX, iCentreY),
                  progress: _greenRipple.value,
                  color: _kGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static double _lerp(double a, double b, double t) =>
      ui.lerpDouble(a, b, t)!;
}

// ─────────────────────────────────────────────────────────────
//  _SustainicLogo
//
//  Renders "Sustainic" as a RichText so each character span can
//  carry its own colour + shadow (glow).  The two 'i' characters
//  animate independently toward blue and green.
// ─────────────────────────────────────────────────────────────
class _SustainicLogo extends StatelessWidget {
  const _SustainicLogo({
    required this.blueGlow,
    required this.greenGlow,
    required this.fontSize,
  });

  /// 0.0 = neutral dark  →  1.0 = full blue  (applied to second 'i')
  final double blueGlow;

  /// 0.0 = neutral dark  →  1.0 = full green (applied to first  'i')
  final double greenGlow;

  final double fontSize;

  static const Color _kDark  = Color(0xFF263238);
  static const Color _kBlue  = Color(0xFF0288D1);
  static const Color _kGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    // Base style shared by every character span
    final TextStyle base = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      color: _kDark,
    );

    // Interpolated colour for each animated 'i'
    final Color blueColor  = Color.lerp(_kDark, _kBlue,  blueGlow)!;
    final Color greenColor = Color.lerp(_kDark, _kGreen, greenGlow)!;

    // Build glow shadow list (empty before animation starts)
    List<Shadow> blueShadow() => blueGlow > 0
        ? [
            Shadow(
              color: const Color(0xFF29B6F6).withValues(alpha: blueGlow * 0.85),
              blurRadius: 20 * blueGlow,
            ),
          ]
        : [];

    List<Shadow> greenShadow() => greenGlow > 0
        ? [
            Shadow(
              color: const Color(0xFF66BB6A).withValues(alpha: greenGlow * 0.85),
              blurRadius: 20 * greenGlow,
            ),
          ]
        : [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── "Susta[i_green]n[i_blue]c" ──────────────────────
        RichText(
          text: TextSpan(
            style: base,
            children: [
              const TextSpan(text: 'Susta'),

              // First 'i' → animates to green
              TextSpan(
                text: 'i',
                style: TextStyle(
                  color: greenColor,
                  shadows: greenShadow(),
                ),
              ),

              const TextSpan(text: 'n'),

              // Second 'i' → animates to blue
              TextSpan(
                text: 'i',
                style: TextStyle(
                  color: blueColor,
                  shadows: blueShadow(),
                ),
              ),

              const TextSpan(text: 'c'),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ── "Technologies" subtitle ──────────────────────────
        Text(
          'Technologies',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF546E7A),
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _DropPainter
//
//  Draws a teardrop / raindrop shape on a 20 × 34 canvas.
//
//  pointAtTop = true  → falling drop  (rounded bulge at bottom,
//                                       pointed tail at top)
//  pointAtTop = false → rising  drop  (rounded bulge at top,
//                                       pointed tail at bottom)
// ─────────────────────────────────────────────────────────────
class _DropPainter extends CustomPainter {
  const _DropPainter({required this.color, required this.pointAtTop});

  final Color color;

  /// true = falling drop (tail at top); false = rising drop (tail at bottom)
  final bool pointAtTop;

  @override
  void paint(Canvas canvas, Size size) {
    final double w  = size.width;
    final double h  = size.height;
    final double cx = w / 2; // horizontal centre of canvas
    final double r  = w / 2; // radius of the circular bulge

    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final Path path = Path();

    if (pointAtTop) {
      // ── Falling drop: bulge at bottom, pointed tail at top ──
      final double cy = h * 0.65; // vertical centre of the bulge

      path.moveTo(cx, 0); // tip at top-centre

      // Right side: cubic from tip down to right equator
      path.cubicTo(
        cx + r * 0.55, h * 0.20, // control 1
        cx + r,        cy,        // control 2
        cx + r,        cy,        // destination
      );

      // Lower arc: right equator → left equator (through the bottom)
      path.arcToPoint(
        Offset(cx - r, cy),
        radius: Radius.circular(r),
        clockwise: false,
      );

      // Left side: cubic from left equator back up to tip
      path.cubicTo(
        cx - r,        cy,        // control 1
        cx - r * 0.55, h * 0.20, // control 2
        cx,            0,         // destination = tip
      );
    } else {
      // ── Rising drop: bulge at top, pointed tail at bottom ──
      final double cy = h * 0.35; // vertical centre of the bulge

      path.moveTo(cx, h); // tip at bottom-centre

      // Left side: cubic from tip up to left equator
      path.cubicTo(
        cx - r * 0.55, h * 0.80, // control 1
        cx - r,        cy,        // control 2
        cx - r,        cy,        // destination
      );

      // Upper arc: left equator → right equator (through the top)
      path.arcToPoint(
        Offset(cx + r, cy),
        radius: Radius.circular(r),
        clockwise: false,
      );

      // Right side: cubic from right equator back down to tip
      path.cubicTo(
        cx + r,        cy,        // control 1
        cx + r * 0.55, h * 0.80, // control 2
        cx,            h,         // destination = tip
      );
    }

    path.close();
    canvas.drawPath(path, fill);

    // Small specular highlight on the rounded bulge for realism
    final double hlCy = pointAtTop ? h * 0.68 : h * 0.32;
    canvas.drawCircle(
      Offset(cx - r * 0.33, hlCy - r * 0.26),
      r * 0.20,
      highlight,
    );
  }

  @override
  bool shouldRepaint(_DropPainter old) =>
      old.color != color || old.pointAtTop != pointAtTop;
}

// ─────────────────────────────────────────────────────────────
//  _RipplePainter
//
//  Draws two concentric expanding rings centred on [center].
//  progress 0 → 1: rings grow outward and fade simultaneously.
// ─────────────────────────────────────────────────────────────
class _RipplePainter extends CustomPainter {
  const _RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  final Offset center;
  final double progress; // 0.0 → 1.0
  final Color  color;

  /// Maximum radius the outer ring reaches
  static const double _kMaxR = 42.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Two rings, the second offset by half a phase for a smoother feel
    _drawRing(canvas, progress,              1.0);
    _drawRing(canvas, (progress + 0.42) % 1, 0.55);
  }

  void _drawRing(Canvas canvas, double t, double alphaScale) {
    final double radius  = _kMaxR * t;
    final double opacity = (1.0 - t) * 0.50 * alphaScale;
    if (opacity <= 0) return;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color       = color.withValues(alpha: opacity)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, 2.8 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress ||
      old.center   != center   ||
      old.color    != color;
}
