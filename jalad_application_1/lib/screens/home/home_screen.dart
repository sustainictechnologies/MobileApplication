import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/eco_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_ActionItem> _actions = [
    _ActionItem(
      icon: Icons.location_on_outlined,
      activeColor: AppColors.primary,
      title: 'Find a Station',
      subtitle: 'Locate refill stations near you',
      route: AppRoutes.map,
    ),
    _ActionItem(
      icon: Icons.history_rounded,
      activeColor: AppColors.accent,
      title: 'My Refills',
      subtitle: 'View your complete refill history',
      route: AppRoutes.history,
    ),
    _ActionItem(
      icon: Icons.eco_rounded,
      activeColor: Color(0xFF00897B),
      title: 'My Eco Impact',
      subtitle: 'Track plastic bottles you\'ve saved',
      route: '/eco-impact',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeBanner(user),
                const SizedBox(height: 28),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                ..._actions.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActionCard(item: item),
                    )),
                const SizedBox(height: 8),
                _buildStatsRow(user),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      expandedHeight: 0,
      title: Row(
        children: [
          const Icon(Icons.water_drop_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            'JALAD',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async {
            await AuthService.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // ── Welcome banner ─────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner(UserModel? user) {
    final firstName = user?.name.split(' ').first ?? 'there';
    final refills   = user?.totalRefills ?? 0;
    final litres    = user?.totalLitresSaved ?? 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $firstName!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to refill? 💧',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _BannerChip(label: '${litres.toStringAsFixed(1)} L saved'),
                  const SizedBox(width: 8),
                  _BannerChip(label: '$refills refills done'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(UserModel? user) {
    final co2     = user?.co2SavedKg ?? 0.0;
    final bottles = user?.plasticBottlesSaved ?? 0.0;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${co2.toStringAsFixed(2)} kg',
            label: 'CO₂ Reduced',
            color: AppColors.accent,
            customIcon: const Co2ReducedIcon(size: 38),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: bottles.toStringAsFixed(0),
            label: 'Bottles Avoided',
            color: AppColors.primary,
            customIcon: const BottlesSavedIcon(size: 38),
          ),
        ),
      ],
    );
  }
}

// ─── Banner chip ──────────────────────────────────────────────────────────────

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Action card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: item.route != null ? () => Navigator.pushNamed(context, item.route!) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.activeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    this.customIcon,
  });

  final String value;
  final String label;
  final Color color;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            if (customIcon != null) customIcon!,
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _ActionItem {
  final IconData icon;
  final Color activeColor;
  final String title;
  final String subtitle;
  final String? route;

  const _ActionItem({
    required this.icon,
    required this.activeColor,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
