import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String _selectedAccountType = 'user';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _switchMode(bool login) {
    if (_isLogin == login) return;
    setState(() {
      _isLogin = login;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await AuthService.instance.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await AuthService.instance.register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          accountType: _selectedAccountType,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildCard(),
              // Demo hint only visible in debug builds — never ships to users
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                _buildDemoHint(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'JALAD',
          style: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 3,
          ),
        ),
        Text(
          'Smart Water Refill',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToggle(),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildNameField(),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildAccountTypeDropdown(),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  if (_errorMessage != null) _buildErrorBanner(),
                  const SizedBox(height: 8),
                  _buildSubmitButton(),
                ],
              ),
            ),
            if (_isLogin) _buildForgotPassword(),
          ],
        ),
      ),
    );
  }

  // ── Mode toggle ────────────────────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ToggleButton(label: 'Login', selected: _isLogin, onTap: () => _switchMode(true)),
          _ToggleButton(label: 'Register', selected: !_isLogin, onTap: () => _switchMode(false)),
        ],
      ),
    );
  }

  // ── Form fields ────────────────────────────────────────────────────────────

  Widget _buildNameField() {
    if (_isLogin) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          hintText: 'Your name',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
        validator: (v) {
          if (_isLogin) return null;
          if (v == null || v.trim().isEmpty) return 'Name is required';
          return null;
        },
      ),
    );
  }

  Widget _buildAccountTypeDropdown() {
    if (_isLogin) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedAccountType,
        decoration: const InputDecoration(
          labelText: 'Account Type',
          prefixIcon: Icon(Icons.account_circle_outlined),
        ),
        items: const [
          DropdownMenuItem(value: 'user',       child: Text('User')),
          DropdownMenuItem(value: 'dealer',     child: Text('Dealer')),
          DropdownMenuItem(value: 'shopkeeper', child: Text('Shopkeeper')),
        ],
        onChanged: (v) => setState(() => _selectedAccountType = v ?? 'user'),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    if (_isLogin) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _confirmCtrl,
        obscureText: _obscureConfirm,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: '••••••',
          prefixIcon: const Icon(Icons.lock_person_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        validator: (v) {
          if (_isLogin) return null;
          if (v == null || v.isEmpty) return 'Please confirm your password';
          if (v != _passwordCtrl.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  // ── Error banner ───────────────────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                _isLogin ? 'Login' : 'Create Account',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            'Forgot password?',
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Demo hint (debug builds only) ─────────────────────────────────────────

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
                children: const [
                  TextSpan(text: 'Demo users: '),
                  TextSpan(
                    text: 'sameer@example.com',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                  TextSpan(text: ' or '),
                  TextSpan(
                    text: 'suraj@example.com',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                  TextSpan(text: ' / '),
                  TextSpan(
                    text: 'password123',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
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

// ─── Toggle button widget ─────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
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
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}