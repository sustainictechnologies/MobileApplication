/// Base URL of the JALAD fake API server.
/// Android emulator → use 10.0.2.2
/// iOS simulator / desktop → use localhost
/// Mobile web (phone browser) → use your machine's local IP
const String kApiBase = 'http://192.168.1.5:3000/api';

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
  static const String stationDetail = '/station/:id';
  static const String refillSession = '/refill';
  static const String ecoImpact = '/eco-impact';
}
