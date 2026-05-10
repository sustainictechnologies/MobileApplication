import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/biometric_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/eco_impact/eco_impact_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/onboarding/intro_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const JalApp());
}

class JalApp extends StatelessWidget {
  const JalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JALAD – Smart Water Refill',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/biometric': (context) => const BiometricScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/eco-impact': (context) => const EcoImpactScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
