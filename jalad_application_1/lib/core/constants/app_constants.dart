/// API base URL — injected at build time via --dart-define=API_BASE=http://x.x.x.x:3000/api
/// Each developer sets their own local IP. See README for instructions.
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://mobileapplication-y4zc.onrender.com/api',
);

class AppConstants {
  AppConstants._();

  static const String appName = 'JALAD';
  static const String appTagline = 'Smart Water Refill';
  static const String appFullName = 'JALAD – Smart Water Refill';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // Water units
  static const String waterUnit = 'L';
  static const double defaultBottleCapacity = 1.0;
  static const double maxBottleCapacity = 5.0;

  // Map defaults
  static const double defaultMapZoom = 14.0;
  static const double defaultSearchRadiusKm = 2.0;
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String ecoImpact = '/eco-impact';
}