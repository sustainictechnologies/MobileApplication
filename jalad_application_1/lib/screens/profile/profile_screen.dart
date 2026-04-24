import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser ?? _placeholder;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 20),
          _ImpactCard(user: user),
          const SizedBox(height: 20),
          _WalletCard(balance: user.walletBalance),
          const SizedBox(height: 20),
          _SettingsSection(
            items: [
              _SettingsItem(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () {}),
              _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
              _SettingsItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
              _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'JALAD v1.0.0',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static final UserModel _placeholder = UserModel(
    id: '',
    name: 'Guest User',
    email: 'guest@example.com',
    totalLitresSaved: 0,
    totalRefills: 0,
    walletBalance: 0,
    createdAt: DateTime.now(),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.primary,
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'J',
                  style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDCEDC8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Your Eco Impact', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImpactStat(value: '${user.totalLitresSaved.toStringAsFixed(0)} L', label: 'Water Saved'),
                _ImpactStat(value: user.plasticBottlesSaved.toStringAsFixed(0), label: 'Bottles Avoided'),
                _ImpactStat(value: '${user.co2SavedKg.toStringAsFixed(1)} kg', label: 'CO₂ Saved'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: AppColors.accent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JALAD Wallet', style: Theme.of(context).textTheme.titleMedium),
                  Text('₹${balance.toStringAsFixed(2)} available', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 38)),
              child: const Text('Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.items});

  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: items
            .map(
              (item) => ListTile(
                leading: Icon(item.icon, color: AppColors.primary, size: 22),
                title: Text(item.label, style: Theme.of(context).textTheme.bodyLarge),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: item.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({required this.icon, required this.label, required this.onTap});
}
