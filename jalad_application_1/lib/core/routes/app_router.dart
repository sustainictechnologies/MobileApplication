import 'package:go_router/go_router.dart';

import '../../screens/history/history_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../constants/app_constants.dart';
import '../../widgets/common/jal_bottom_nav.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => JalBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.map,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MapScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);
