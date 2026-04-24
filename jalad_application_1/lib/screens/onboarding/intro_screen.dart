import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  static const List<_PageData> _pages = [
    _PageData(
      backgroundColor: Colors.white,
      imagePath: 'assets/images/onboarding_1.png',
      placeholderIcon: Icons.person_outline_rounded,
      placeholderBgColor: Color(0xFFE3F2FD),
      placeholderIconColor: Color(0xFF1565C0),
      titleSpans: [
        TextSpan(
          text: 'Microplastics\n',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w800,
            fontSize: 32,
            height: 1.2,
          ),
        ),
        TextSpan(
          text: 'Are ',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w400,
            fontSize: 30,
          ),
        ),
        TextSpan(
          text: 'Inside You',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
      ],
      description: 'Tiny plastic particles are in your water,\nfood & air.',
      highlightSpans: [
        TextSpan(
          text: 'You may be consuming plastic every day.',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    ),
    _PageData(
      backgroundColor: Color(0xFFF1F8E9),
      imagePath: 'assets/images/onboarding_2.png',
      placeholderIcon: Icons.factory_outlined,
      placeholderBgColor: Color(0xFFC8E6C9),
      placeholderIconColor: Color(0xFF2E7D32),
      titleSpans: [
        TextSpan(
          text: 'Every Bottle\n',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            fontSize: 30,
            height: 1.2,
          ),
        ),
        TextSpan(
          text: 'Has a ',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            fontSize: 30,
          ),
        ),
        TextSpan(
          text: 'Carbon Cost',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
      ],
      description: 'Plastic bottles create pollution\n& carbon emissions.',
      highlightSpans: [
        TextSpan(
          text: 'Small choices ',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        TextSpan(
          text: '→ ',
          style: TextStyle(color: Color(0xFF2E7D32), fontSize: 15),
        ),
        TextSpan(
          text: 'Big environmental impact',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ],
    ),
    _PageData(
      backgroundColor: Colors.white,
      imagePath: 'assets/images/onboarding_3.png',
      placeholderIcon: Icons.water_drop_rounded,
      placeholderBgColor: Color(0xFFE8F5E9),
      placeholderIconColor: Color(0xFF2E7D32),
      titleSpans: [
        TextSpan(
          text: 'Refill ',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w800,
            fontSize: 30,
            height: 1.2,
          ),
        ),
        TextSpan(
          text: 'is the\n',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            fontSize: 30,
          ),
        ),
        TextSpan(
          text: 'Future',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
      ],
      description: 'Find refill stations. Cut plastic waste.\nReduce your carbon footprint.',
      highlightSpans: [
        TextSpan(
          text: 'Drink smart. ',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        TextSpan(
          text: 'Live green.',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    ),
  ];

  void _animateTo(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );

  void _next() {
    if (_current < _pages.length - 1) {
      _animateTo(_current + 1);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _previous() => _animateTo(_current - 1);
  void _skip() => Navigator.pushReplacementNamed(context, '/login');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _IntroPage(data: _pages[i]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              current: _current,
              total: _pages.length,
              isFirst: _current == 0,
              isLast: _current == _pages.length - 1,
              onSkip: _skip,
              onPrevious: _previous,
              onNext: _next,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page widget ──────────────────────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.data});

  final _PageData data;

  static const double _bottomBarHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: data.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Text section (top) ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: Column(
                children: [
                  // Title
                  Text.rich(
                    TextSpan(children: data.titleSpans),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Description
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF666666),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Highlight (plain text, no box)
                  Text.rich(
                    TextSpan(children: data.highlightSpans),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Illustration (fills remaining space) ────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: _bottomBarHeight),
                child: _Illustration(
                  imagePath: data.imagePath,
                  bgColor: data.placeholderBgColor,
                  icon: data.placeholderIcon,
                  iconColor: data.placeholderIconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Illustration widget ──────────────────────────────────────────────────────

class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.imagePath,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
  });

  final String imagePath;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.asset(
          imagePath,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildPlaceholder(constraints),
        );
      },
    );
  }

  Widget _buildPlaceholder(BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            'Place image at:\n$imagePath',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: iconColor.withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.current,
    required this.total,
    required this.isFirst,
    required this.isLast,
    required this.onSkip,
    required this.onPrevious,
    required this.onNext,
  });

  final int current;
  final int total;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const Color _activeBlue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        28,
        16,
        28,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Skip or Previous
          SizedBox(
            width: 72,
            child: TextButton(
              onPressed: isFirst ? onSkip : onPrevious,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isFirst ? 'Skip' : 'Previous',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ),

          // Center: dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(total, (i) {
              final active = i == current;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? _activeBlue : const Color(0xFFD0D0D0),
                ),
              );
            }),
          ),

          // Right: Next or Get Started
          SizedBox(
            width: 72,
            child: TextButton(
              onPressed: onNext,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isLast ? 'Get Started' : 'Next',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _activeBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page data model ──────────────────────────────────────────────────────────

class _PageData {
  final Color backgroundColor;
  final String imagePath;
  final IconData placeholderIcon;
  final Color placeholderBgColor;
  final Color placeholderIconColor;
  final List<InlineSpan> titleSpans;
  final String description;
  final List<InlineSpan> highlightSpans;

  const _PageData({
    required this.backgroundColor,
    required this.imagePath,
    required this.placeholderIcon,
    required this.placeholderBgColor,
    required this.placeholderIconColor,
    required this.titleSpans,
    required this.description,
    required this.highlightSpans,
  });
}
