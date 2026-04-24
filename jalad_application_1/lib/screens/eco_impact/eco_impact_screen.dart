import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/eco_icons.dart';

// ─── Environment tab enum ─────────────────────────────────────────────────────

enum _EnvTab { forest, ocean }

// ─── Entry point ──────────────────────────────────────────────────────────────

class EcoImpactScreen extends StatefulWidget {
  const EcoImpactScreen({super.key});

  @override
  State<EcoImpactScreen> createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen>
    with TickerProviderStateMixin {

  // ── Mutable state ───────────────────────────────────────────────────────────
  int _bottlesSaved = 97;
  _EnvTab _activeTab = _EnvTab.forest;

  // ── Derived stats ───────────────────────────────────────────────────────────
  double get _treesEquivalent => (_bottlesSaved * 0.05);
  double get _waterLitres     => (_bottlesSaved * 0.5);
  double get _co2Reduced      => (_bottlesSaved * 0.2);

  // ── Level config ────────────────────────────────────────────────────────────
  static const int _levelTarget = 200;
  int get _levelCurrent => 4;
  double get _levelProgress => (_bottlesSaved / _levelTarget).clamp(0.0, 1.0);

  // ── Weekly data ─────────────────────────────────────────────────────────────
  static const List<int>    _weeklyBottles = [8, 12, 6, 15, 9, 18, 7];
  static const List<String> _weekDays      = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // ── Achievements ────────────────────────────────────────────────────────────
  static const List<_AchievementData> _achievements = [
    _AchievementData(
      emoji: '✅', icon: Icons.water_drop_rounded,
      label: 'First Refill',   subtitle: 'Completed your first refill',
      unlocked: true,  color: Color(0xFF0288D1),
    ),
    _AchievementData(
      emoji: '✅', icon: Icons.recycling_rounded,
      label: 'Saved 50 Bottles', subtitle: 'Avoided 50 plastic bottles',
      unlocked: true,  color: Color(0xFF388E3C),
    ),
    _AchievementData(
      emoji: '🔒', icon: Icons.waves_rounded,
      label: 'Ocean Protector',  subtitle: 'Unlock at 100 bottles',
      unlocked: false, color: Color(0xFF0277BD),
    ),
    _AchievementData(
      emoji: '🔒', icon: Icons.forest_rounded,
      label: 'Tree Guardian',    subtitle: 'Unlock at 200 bottles',
      unlocked: false, color: Color(0xFF2E7D32),
    ),
  ];

  // ── Animation controllers ───────────────────────────────────────────────────
  late final AnimationController _forestCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _statsCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _refillCtrl;

  late final Animation<double> _forestGrowth;
  late final Animation<double> _statsFade;
  late final Animation<double> _statsSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _refillScale;

  @override
  void initState() {
    super.initState();

    _forestCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400),
    )..forward();

    _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 4),
    )..repeat();

    _statsCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _refillCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 180),
    );

    _forestGrowth = CurvedAnimation(parent: _forestCtrl, curve: Curves.easeOutCubic);

    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);

    _statsSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _refillScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _refillCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _forestCtrl.dispose();
    _waveCtrl.dispose();
    _statsCtrl.dispose();
    _pulseCtrl.dispose();
    _refillCtrl.dispose();
    super.dispose();
  }

  // ── Refill action ───────────────────────────────────────────────────────────

  Future<void> _onRefill() async {
    await _refillCtrl.forward();
    await _refillCtrl.reverse();
    setState(() {
      _bottlesSaved++;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💧 Refill recorded! $_bottlesSaved bottles saved.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1 ── Motivational banner
            _buildMotivationalBanner(),
            const SizedBox(height: 22),

            // 2 ── Stat cards (horizontal scroll)
            _buildStatCardsRow(),
            const SizedBox(height: 26),

            // 3+4 ── Environment toggle + scene
            _buildSectionTitle('Your Environment'),
            const SizedBox(height: 12),
            _buildEnvToggle(),
            const SizedBox(height: 12),
            _buildEnvScene(),
            const SizedBox(height: 26),

            // 5 ── Achievements
            _buildSectionTitle('Achievements'),
            const SizedBox(height: 12),
            _buildAchievements(),
            const SizedBox(height: 26),

            // 6 ── Level progress
            _buildSectionTitle('Level Progress'),
            const SizedBox(height: 12),
            _buildLevelProgress(),
            const SizedBox(height: 26),

            // 7 ── Weekly chart
            _buildSectionTitle('Weekly Impact'),
            const SizedBox(height: 12),
            _buildWeeklyChart(),
          ],
        ),
      ),
      // 8 ── Action button
      floatingActionButton: _buildRefillButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // Section builders
  // ══════════════════════════════════════════════════════════════════════════════

  // ── App bar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'My Eco Impact',
        style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
            tooltip: 'Share Impact',
          ),
        ),
      ],
    );
  }

  // ── Section title ────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
    );
  }

  // ── 1. Motivational banner ───────────────────────────────────────────────────

  Widget _buildMotivationalBanner() {
    return AnimatedBuilder(
      animation: _statsCtrl,
      builder: (context, child) => Opacity(
        opacity: _statsFade.value,
        child: Transform.translate(offset: Offset(0, _statsSlide.value), child: child),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), AppColors.primary, Color(0xFF00897B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Great work, Eco Champion! 🌿',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You\'ve saved $_bottlesSaved bottles & ${_treesEquivalent.toStringAsFixed(1)} tree equivalents this month!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Stat cards row ────────────────────────────────────────────────────────

  Widget _buildStatCardsRow() {
    return SizedBox(
      height: 122,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          EcoStatCard(
            customIcon: const BottlesSavedIcon(size: 32),
            value: '$_bottlesSaved',
            label: 'Plastic Bottles\nSaved',
            gradientColors: const [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          const SizedBox(width: 12),
          EcoStatCard(
            icon: Icons.park_rounded,
            value: _treesEquivalent.toStringAsFixed(1),
            label: 'Trees\nEquivalent',
            gradientColors: const [Color(0xFF33691E), Color(0xFF8BC34A)],
          ),
          const SizedBox(width: 12),
          EcoStatCard(
            customIcon: const WaterSavedIcon(size: 32),
            value: '${_waterLitres.toStringAsFixed(1)} L',
            label: 'Water\nSaved',
            gradientColors: const [Color(0xFF0277BD), Color(0xFF29B6F6)],
          ),
          const SizedBox(width: 12),
          EcoStatCard(
            customIcon: const Co2ReducedIcon(size: 32),
            value: '${_co2Reduced.toStringAsFixed(1)} kg',
            label: 'CO₂\nReduced',
            gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
          ),
        ],
      ),
    );
  }

  // ── 3. Environment toggle ────────────────────────────────────────────────────

  Widget _buildEnvToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _EnvToggleBtn(
            label: '🌳  Forest',
            selected: _activeTab == _EnvTab.forest,
            onTap: () => setState(() => _activeTab = _EnvTab.forest),
          ),
          _EnvToggleBtn(
            label: '🌊  Ocean',
            selected: _activeTab == _EnvTab.ocean,
            onTap: () => setState(() => _activeTab = _EnvTab.ocean),
          ),
        ],
      ),
    );
  }

  // ── 4. Environment scene (Forest / Ocean) ────────────────────────────────────

  Widget _buildEnvScene() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 480),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _activeTab == _EnvTab.forest
              ? _ForestScene(
                  key: const ValueKey('forest'),
                  forestGrowth: _forestGrowth,
                  waveCtrl: _waveCtrl,
                  bottlesSaved: _bottlesSaved,
                )
              : _OceanScene(
                  key: const ValueKey('ocean'),
                  waveCtrl: _waveCtrl,
                  bottlesSaved: _bottlesSaved,
                ),
        ),
      ),
    );
  }

  // ── 5. Achievements ─────────────────────────────────────────────────────────

  Widget _buildAchievements() {
    final unlockedCount = _achievements.where((a) => a.unlocked).length;
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$unlockedCount / ${_achievements.length} Unlocked',
                  style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5, fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._achievements.map((a) => _AchievementItem(data: a)),
          ],
        ),
      ),
    );
  }

  // ── 6. Level progress ────────────────────────────────────────────────────────

  Widget _buildLevelProgress() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $_levelCurrent – Forest Guardian',
                      style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_bottlesSaved / $_levelTarget Trees',
                      style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forest_rounded, color: AppColors.primary, size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated progress bar (re-animates on value change)
            EcoProgressBar(progress: _levelProgress),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_levelProgress * 100).toInt()}% complete',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5, color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_levelTarget - _bottlesSaved} more to go',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5, color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            Text(
              'Next Rewards',
              style: GoogleFonts.poppins(
                fontSize: 12.5, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: const [
                _RewardChip(label: 'Grow 1 Tree 🌱'),
                _RewardChip(label: 'Unlock Bird 🐦'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 7. Weekly bar chart ──────────────────────────────────────────────────────

  Widget _buildWeeklyChart() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bottles Saved',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'This Week',
                    style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: WeeklyBarChart(
                bottles: _weeklyBottles,
                days: _weekDays,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 8. Refill water button ───────────────────────────────────────────────────

  Widget _buildRefillButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _refillScale,
        builder: (context, child) =>
            Transform.scale(scale: _refillScale.value, child: child),
        child: GestureDetector(
          onTap: _onRefill,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), AppColors.primary, Color(0xFF00897B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 18, offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  '💧  Refill Water',
                  style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reusable widgets
// ══════════════════════════════════════════════════════════════════════════════

// ─── Stat card ────────────────────────────────────────────────────────────────

class EcoStatCard extends StatelessWidget {
  const EcoStatCard({
    super.key,
    this.icon,
    this.customIcon,
    required this.value,
    required this.label,
    required this.gradientColors,
  });

  final IconData?    icon;
  final Widget?      customIcon;
  final String       value;
  final String       label;
  final List<Color>  gradientColors;

  @override
  Widget build(BuildContext context) {
    final primary = gradientColors[0];
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.13),
            gradientColors[1].withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.10),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          customIcon ?? Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: primary, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w800, color: primary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.5, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500, height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Achievement item ─────────────────────────────────────────────────────────

class _AchievementItem extends StatelessWidget {
  const _AchievementItem({required this.data});
  final _AchievementData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.unlocked
                  ? data.color.withValues(alpha: 0.12)
                  : const Color(0xFFF0F0F0),
              border: Border.all(
                color: data.unlocked
                    ? data.color.withValues(alpha: 0.4)
                    : const Color(0xFFDDDDDD),
                width: 1.5,
              ),
              boxShadow: data.unlocked
                  ? [BoxShadow(color: data.color.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Icon(
              data.icon,
              color: data.unlocked ? data.color : const Color(0xFFBBBBBB),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.emoji}  ${data.label}',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5, fontWeight: FontWeight.w600,
                    color: data.unlocked ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5, color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          if (data.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  fontSize: 10.5, fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFBBBBBB)),
        ],
      ),
    );
  }
}

// ─── Eco progress bar (TweenAnimationBuilder re-animates on value change) ─────

class EcoProgressBar extends StatelessWidget {
  const EcoProgressBar({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Stack(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly bar chart ─────────────────────────────────────────────────────────

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.bottles, required this.days});
  final List<int>    bottles;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    final maxVal = bottles.reduce(math.max).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(bottles.length, (i) {
        final ratio  = bottles[i] / maxVal;
        final isMax  = bottles[i] == bottles.reduce(math.max);
        final barH   = 80.0 * ratio;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${bottles[i]}',
              style: GoogleFonts.poppins(
                fontSize: 9.5, fontWeight: FontWeight.w600,
                color: isMax ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: barH),
              duration: Duration(milliseconds: 600 + i * 80),
              curve: Curves.easeOutCubic,
              builder: (context, h, _) => Container(
                width: 28, height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMax
                        ? [const Color(0xFF1B5E20), AppColors.primaryLight]
                        : [
                            AppColors.primary.withValues(alpha: 0.5),
                            AppColors.primaryLight.withValues(alpha: 0.4),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: isMax
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              days[i],
              style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Forest scene widget
// ══════════════════════════════════════════════════════════════════════════════

class _ForestScene extends StatelessWidget {
  const _ForestScene({
    super.key,
    required this.forestGrowth,
    required this.waveCtrl,
    required this.bottlesSaved,
  });

  final Animation<double>     forestGrowth;
  final AnimationController   waveCtrl;
  final int                   bottlesSaved;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([forestGrowth, waveCtrl]),
      builder: (context, _) => CustomPaint(
        painter: _ForestPainter(
          growthProgress: forestGrowth.value,
          waveProgress:   waveCtrl.value,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _SceneLabel(
              icon: Icons.park_rounded,
              text: "You're growing a forest: $bottlesSaved trees planted",
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Ocean scene widget
// ══════════════════════════════════════════════════════════════════════════════

class _OceanScene extends StatelessWidget {
  const _OceanScene({
    super.key,
    required this.waveCtrl,
    required this.bottlesSaved,
  });

  final AnimationController waveCtrl;
  final int                 bottlesSaved;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveCtrl,
      builder: (context, _) => CustomPaint(
        painter: _OceanPainter(waveProgress: waveCtrl.value),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _SceneLabel(
              icon: Icons.water,
              text: 'Seas are cleaner: $bottlesSaved bottles reduced',
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scene label overlay ─────────────────────────────────────────────────────

class _SceneLabel extends StatelessWidget {
  const _SceneLabel({required this.icon, required this.text});
  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Painters
// ══════════════════════════════════════════════════════════════════════════════

// ─── Forest painter ──────────────────────────────────────────────────────────

class _ForestPainter extends CustomPainter {
  const _ForestPainter({required this.growthProgress, required this.waveProgress});

  final double growthProgress;
  final double waveProgress;

  static const List<_TreeData> _trees = [
    _TreeData(xFraction: 0.05, sizeFactor: 0.70, delay: 0.00),
    _TreeData(xFraction: 0.15, sizeFactor: 0.90, delay: 0.08),
    _TreeData(xFraction: 0.26, sizeFactor: 0.75, delay: 0.16),
    _TreeData(xFraction: 0.38, sizeFactor: 1.00, delay: 0.04),
    _TreeData(xFraction: 0.50, sizeFactor: 0.85, delay: 0.20),
    _TreeData(xFraction: 0.61, sizeFactor: 0.95, delay: 0.12),
    _TreeData(xFraction: 0.73, sizeFactor: 0.80, delay: 0.24),
    _TreeData(xFraction: 0.84, sizeFactor: 1.00, delay: 0.06),
    _TreeData(xFraction: 0.93, sizeFactor: 0.70, delay: 0.18),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawGround(canvas, size);
    for (final t in _trees) { _drawTree(canvas, size, t); }
    _drawWater(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB2EBF2), Color(0xFFE8F5E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.82, size.height * 0.20);
    canvas.drawCircle(c, 18, Paint()..color = const Color(0xFFFFF176));
    canvas.drawCircle(
      c, 26,
      Paint()
        ..color = const Color(0xFFFFF9C4).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.70);
    _cloud(canvas, p, Offset(size.width * 0.18, size.height * 0.15), 28);
    _cloud(canvas, p, Offset(size.width * 0.54, size.height * 0.10), 22);
  }

  void _cloud(Canvas canvas, Paint p, Offset c, double r) {
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c.translate(r * 0.9,  r * 0.1), r * 0.7, p);
    canvas.drawCircle(c.translate(-r * 0.8, r * 0.1), r * 0.6, p);
  }

  void _drawGround(Canvas canvas, Size size) {
    final top = size.height * 0.70;
    final path = Path()
      ..moveTo(0, top + 6)
      ..quadraticBezierTo(size.width * 0.25, top - 6,  size.width * 0.50, top + 4)
      ..quadraticBezierTo(size.width * 0.75, top + 14, size.width,        top + 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, top, size.width, size.height - top)),
    );
  }

  void _drawTree(Canvas canvas, Size size, _TreeData t) {
    final progress = ((growthProgress - t.delay) / (1 - t.delay)).clamp(0.0, 1.0);
    if (progress <= 0) return;

    final x       = size.width * t.xFraction;
    final groundY = size.height * 0.72;
    final treeH   = size.height * 0.30 * t.sizeFactor * progress;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, groundY - treeH * 0.18),
          width: 5.0 * t.sizeFactor, height: treeH * 0.36,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF5D4037),
    );

    // Three-layer canopy (dark → light)
    final colors  = [const Color(0xFF1B5E20), const Color(0xFF2E7D32), const Color(0xFF388E3C)];
    final widths  = [0.65, 0.80, 1.0];
    double layerY = groundY - treeH * 0.36;

    for (int i = 0; i < 3; i++) {
      final layerH = treeH * 0.35;
      final halfW  = treeH * 0.45 * t.sizeFactor * widths[i] * progress;
      canvas.drawPath(
        Path()
          ..moveTo(x, layerY - layerH)
          ..lineTo(x + halfW, layerY + layerH * 0.2)
          ..lineTo(x - halfW, layerY + layerH * 0.2)
          ..close(),
        Paint()..color = colors[i],
      );
      layerY -= layerH * 0.55;
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final top  = size.height * 0.84;
    final path = Path()..moveTo(0, top);
    final segW = size.width / 5;

    for (int i = 0; i < 5; i++) {
      final y1 = math.sin((waveProgress * 2 * math.pi) + i * math.pi / 2) * 8.0;
      final y2 = math.sin((waveProgress * 2 * math.pi) + (i + 0.5) * math.pi / 2) * 8.0;
      path.cubicTo(
        i * segW + segW * 0.25, top + y1,
        i * segW + segW * 0.75, top + y2,
        (i + 1) * segW,         top + y1,
      );
    }
    path..lineTo(size.width, size.height)..lineTo(0, size.height)..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0288D1).withValues(alpha: 0.70),
            const Color(0xFF29B6F6).withValues(alpha: 0.50),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, top, size.width, size.height - top)),
    );
  }

  @override
  bool shouldRepaint(_ForestPainter old) =>
      old.growthProgress != growthProgress || old.waveProgress != waveProgress;
}

// ─── Ocean painter ────────────────────────────────────────────────────────────

class _OceanPainter extends CustomPainter {
  const _OceanPainter({required this.waveProgress});
  final double waveProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawSurface(canvas, size);
    _drawBubbles(canvas, size);
    // Fish: orange, yellow, cyan
    _drawFish(canvas, Offset(size.width * 0.20, size.height * 0.55), 18, const Color(0xFFFF7043));
    _drawFish(canvas, Offset(size.width * 0.60, size.height * 0.68), 13, const Color(0xFFFFD54F));
    _drawFish(canvas, Offset(size.width * 0.80, size.height * 0.42), 15, const Color(0xFF80DEEA));
    _drawTurtle(canvas, Offset(size.width * 0.42, size.height * 0.80));
    _drawSeaFloor(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF0288D1), Color(0xFF4FC3F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _drawSurface(Canvas canvas, Size size) {
    final segW = size.width / 4;
    final path = Path()..moveTo(0, 0);
    for (int i = 0; i < 4; i++) {
      final y = math.sin((waveProgress * 2 * math.pi) + i) * 5.0;
      path.quadraticBezierTo(
        i * segW + segW * 0.5, y + 10,
        (i + 1) * segW,         y,
      );
    }
    path..lineTo(size.width, size.height * 0.12)..lineTo(0, size.height * 0.12)..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.10));
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.18);
    final offsets = [
      Offset(size.width * 0.12, size.height * 0.38 - waveProgress * 10),
      Offset(size.width * 0.38, size.height * 0.58 - waveProgress * 8),
      Offset(size.width * 0.72, size.height * 0.28 - waveProgress * 12),
      Offset(size.width * 0.90, size.height * 0.62 - waveProgress * 7),
    ];
    for (final o in offsets) {
      canvas.drawCircle(o, 4, p);
      canvas.drawCircle(o.translate(10, 18), 2.5, p);
    }
  }

  void _drawFish(Canvas canvas, Offset pos, double s, Color color) {
    // Body
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: s * 2.4, height: s * 1.1),
      Paint()..color = color,
    );
    // Tail
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx + s * 1.2, pos.dy)
        ..lineTo(pos.dx + s * 2.0, pos.dy - s * 0.7)
        ..lineTo(pos.dx + s * 2.0, pos.dy + s * 0.7)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.75),
    );
    // Eye
    canvas.drawCircle(
      Offset(pos.dx - s * 0.5, pos.dy - s * 0.1), s * 0.18,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(pos.dx - s * 0.5, pos.dy - s * 0.1), s * 0.10,
      Paint()..color = Colors.black.withValues(alpha: 0.60),
    );
  }

  void _drawTurtle(Canvas canvas, Offset pos) {
    const s = 20.0;
    // Shell
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: s * 2.0, height: s * 1.5),
      Paint()..color = const Color(0xFF2E7D32),
    );
    // Shell pattern
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: s * 1.1, height: s * 0.8),
      Paint()
        ..color = const Color(0xFF1B5E20)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    // Head
    canvas.drawCircle(
      Offset(pos.dx - s * 1.1, pos.dy), s * 0.45,
      Paint()..color = const Color(0xFF4CAF50),
    );
    // Flippers (top & bottom)
    for (final flip in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + flip * s * 0.88),
          width: s * 1.2, height: s * 0.4,
        ),
        Paint()..color = const Color(0xFF388E3C),
      );
    }
  }

  void _drawSeaFloor(Canvas canvas, Size size) {
    final top  = size.height * 0.87;
    final path = Path()
      ..moveTo(0, top + size.height * 0.03)
      ..quadraticBezierTo(size.width * 0.25, top - size.height * 0.02, size.width * 0.5,  top + size.height * 0.02)
      ..quadraticBezierTo(size.width * 0.75, top + size.height * 0.06, size.width,        top + size.height * 0.01)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, top, size.width, size.height - top)),
    );
    // Seaweed
    _seaweed(canvas, Offset(size.width * 0.08,  top + size.height * 0.02));
    _seaweed(canvas, Offset(size.width * 0.55,  top));
    _seaweed(canvas, Offset(size.width * 0.86,  top + size.height * 0.02));
  }

  void _seaweed(Canvas canvas, Offset base) {
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(base.dx + 7,  base.dy - 10, base.dx,      base.dy - 20)
        ..quadraticBezierTo(base.dx - 7,  base.dy - 30, base.dx,      base.dy - 38),
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_OceanPainter old) => old.waveProgress != waveProgress;
}

// ══════════════════════════════════════════════════════════════════════════════
// Environment toggle button
// ══════════════════════════════════════════════════════════════════════════════

class _EnvToggleBtn extends StatelessWidget {
  const _EnvToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8, offset: const Offset(0, 2),
                  )]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reward chip ─────────────────────────────────────────────────────────────

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Data models
// ══════════════════════════════════════════════════════════════════════════════

class _AchievementData {
  const _AchievementData({
    required this.emoji,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.unlocked,
    required this.color,
  });

  final String   emoji;
  final IconData icon;
  final String   label;
  final String   subtitle;
  final bool     unlocked;
  final Color    color;
}

class _TreeData {
  const _TreeData({
    required this.xFraction,
    required this.sizeFactor,
    required this.delay,
  });

  final double xFraction;
  final double sizeFactor;
  final double delay;
}
