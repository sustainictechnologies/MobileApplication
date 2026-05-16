import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isTopping = false;

  Future<void> _handleTopUp() async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _TopUpDialog(),
    );
    if (amount == null || !mounted) return;

    setState(() => _isTopping = true);
    try {
      await WalletService.instance.topUp(amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹${amount.toStringAsFixed(0)} added to your wallet!'),
            backgroundColor: AppColors.primary,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isTopping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user  = AuthService.instance.currentUser ?? _placeholder;
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
          _WalletCard(
            balance:   user.walletBalance,
            isLoading: _isTopping,
            onTopUp:   _handleTopUp,
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            items: [
              _SettingsItem(icon: Icons.edit_outlined,         label: 'Edit Profile',     onTap: () {}),
              _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications',    onTap: () {}),
              _SettingsItem(icon: Icons.help_outline,           label: 'Help & Support',   onTap: () {}),
              _SettingsItem(icon: Icons.privacy_tip_outlined,   label: 'Privacy Policy',   onTap: () {}),
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
            icon:  const Icon(Icons.logout_rounded, color: AppColors.error),
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

// ─── Top Up dialog ────────────────────────────────────────────────────────────

class _TopUpDialog extends StatefulWidget {
  const _TopUpDialog();

  @override
  State<_TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<_TopUpDialog> {
  final _controller = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  static const _presets = [50.0, 100.0, 200.0, 500.0];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_controller.text.trim());
    if (amount != null) Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Top Up Wallet',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick-select preset amounts
            Wrap(
              spacing: 8,
              children: _presets.map((amt) {
                return ActionChip(
                  label: Text(
                    '₹${amt.toInt()}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  onPressed: () {
                    _controller.text = amt.toInt().toString();
                    _controller.selection = TextSelection.collapsed(
                      offset: _controller.text.length,
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Enter amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
              onFieldSubmitted: (_) => _confirm(),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Enter a valid amount';
                if (n > 10000) return 'Maximum top-up is ₹10,000';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Add Money', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─── Wallet card ──────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.balance,
    required this.onTopUp,
    required this.isLoading,
  });

  final double        balance;
  final VoidCallback  onTopUp;
  final bool          isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.accent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JALAD Wallet',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('₹${balance.toStringAsFixed(2)} available',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : onTopUp,
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 38)),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header ───────────────────────────────────────────────────────────

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
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'J',
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.email,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Impact card ──────────────────────────────────────────────────────────────

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
                Text('Your Eco Impact',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImpactStat(
                    value: '${user.totalLitresSaved.toStringAsFixed(0)} L',
                    label: 'Water Saved'),
                _ImpactStat(
                    value: user.plasticBottlesSaved.toStringAsFixed(0),
                    label: 'Bottles Avoided'),
                _ImpactStat(
                    value: '${user.co2SavedKg.toStringAsFixed(1)} kg',
                    label: 'CO₂ Saved'),
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
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 11)),
      ],
    );
  }
}

// ─── Settings ─────────────────────────────────────────────────────────────────

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
                title: Text(item.label,
                    style: Theme.of(context).textTheme.bodyLarge),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: item.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData      icon;
  final String        label;
  final VoidCallback  onTap;

  const _SettingsItem(
      {required this.icon, required this.label, required this.onTap});
}