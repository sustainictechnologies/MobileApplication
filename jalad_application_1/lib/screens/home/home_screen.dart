import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/eco_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(user),
            const SizedBox(height: 16),
            _buildQuoteCard(),
            const SizedBox(height: 16),
            _buildStatsCard(user),
          ],
        ),
      ),
      floatingActionButton: _buildRefillFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 26),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2E7D32),
            ),
            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'JALAD',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary, size: 26),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded,
              color: AppColors.textPrimary, size: 26),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  // ── Welcome banner ─────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner(UserModel? user) {
    final firstName = user?.name.split(' ').first ?? 'there';
    final litres    = user?.totalLitresSaved ?? 0.0;
    final refills   = user?.totalRefills ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Background: water drop image
            Positioned.fill(
              child: Image.asset(
                'assets/images/water_drop.png',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay so text stays readable
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1FA971).withValues(alpha: 0.88),
                      const Color(0xFF34D399).withValues(alpha: 0.72),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Foreground: text + stats
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '$firstName!',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ready to refill? 💧',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop_rounded,
                            color: Color(0xFF29B6F6), size: 22),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${litres.toStringAsFixed(1)} L',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Saved',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        const Icon(Icons.refresh_rounded,
                            color: Color(0xFF1FA971), size: 22),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$refills',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Refills done',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ── Quote card ─────────────────────────────────────────────────────────────

  Widget _buildQuoteCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Row(
        children: [
          // Left: photo image with blend fade
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.55, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/quote_banner.png',
                width: 145,
                height: 185,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Right: quote text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '““',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Every drop you save today, builds a better tomorrow.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                            color: AppColors.primary.withValues(alpha: 0.35)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.water_drop_rounded,
                            color: AppColors.primary, size: 12),
                      ),
                      Expanded(
                        child: Divider(
                            color: AppColors.primary.withValues(alpha: 0.35)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Refill. Reuse. Reduce.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats card ─────────────────────────────────────────────────────────────

  Widget _buildStatsCard(UserModel? user) {
    final co2     = user?.co2SavedKg ?? 0.0;
    final bottles = user?.plasticBottlesSaved ?? 0.0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Co2ReducedIcon(size: 52),
                  const SizedBox(height: 10),
                  Text( 
                    '${co2.toStringAsFixed(2)} kg',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'CO₂ Saved',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 70, color: Colors.grey.shade200),
            Expanded(
              child: Column(
                children: [
                  const BottlesSavedIcon(size: 52),
                  const SizedBox(height: 10),
                  Text(
                    bottles.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Bottles Avoided',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  // ── Refill FAB ─────────────────────────────────────────────────────────────

  void _showQrCode(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: _QrSheet(user: AuthService.instance.currentUser),
      ),
    );
  }

  Widget _buildRefillFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQrCode(context),
      child: Container(
        width: 78,
        height: 78,
        decoration: const BoxDecoration(
          color: Color(0xFF1565C0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x441565C0),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text(
              'Refill',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, UserModel? user) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1FA971), Color(0xFF34D399)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(context, Icons.home_rounded, 'Home', '/home'),
                _drawerItem(context, Icons.location_on_outlined, 'Find Stations', '/map'),
                _drawerItem(context, Icons.history_rounded, 'My Refills', '/history'),
                _drawerItem(context, Icons.eco_rounded, 'Eco Impact', '/eco-impact'),
                _drawerItem(context, Icons.person_outline_rounded, 'Profile', '/profile'),
                _drawerItem(context, Icons.notifications_outlined, 'Notifications', '/notifications'),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    await AuthService.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() => _currentIndex = i);
        switch (i) {
          case 1:
            Navigator.pushNamed(context, AppRoutes.map);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.history);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.ecoImpact);
            break;
        }
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 12,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          activeIcon: Icon(Icons.location_on_rounded),
          label: 'Stations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco_rounded),
          label: 'Impact',
        ),
      ],
    );
  }
}

// ─── QR Code bottom sheet ─────────────────────────────────────────────────────

class _QrSheet extends StatelessWidget {
  const _QrSheet({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final qrCode = user?.qrCode;
    final name   = user?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button row
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'My QR Code',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (qrCode != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrCode,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF2E7D32),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  'Show this at the water station to refill',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Icon(Icons.qr_code_rounded, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'QR code not available',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign out and log in again\nto generate your QR code.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
