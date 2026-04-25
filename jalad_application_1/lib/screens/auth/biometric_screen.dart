import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../services/auth_service.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final _localAuth = LocalAuthentication();

  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Trigger biometric prompt automatically on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        if (!mounted) return;
        // Device has no biometrics — skip to home directly
        await _onSuccess();
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to continue',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/pattern as fallback
          stickyAuth: true,     // keep prompt open if app goes background
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        await _onSuccess();
      } else {
        setState(() => _error = 'Authentication cancelled. Try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Biometric error. Please try again.');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _onSuccess() async {
    // Refresh the JWT so the 7-day window resets
    try {
      await AuthService.instance.refreshToken();
    } catch (_) {
      // Refresh failing is non-fatal — current token still valid
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _signOut() {
    AuthService.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App icon / branding
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Welcome back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AuthService.instance.currentUser?.name ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // Biometric icon button
              GestureDetector(
                onTap: _isAuthenticating ? null : _authenticate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isAuthenticating
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: _isAuthenticating
                        ? null
                        : [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: _isAuthenticating
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.fingerprint_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isAuthenticating
                    ? 'Verifying...'
                    : 'Tap to authenticate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Use different account
              TextButton(
                onPressed: _signOut,
                child: Text(
                  'Use a different account',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}