/// App-wide constants
class AppConstants {
  // Time thresholds
  static const Duration offlineThreshold = Duration(seconds: 90);

  // Weight limits (grams)
  static const int minTargetWeight = 50;
  static const int maxTargetWeight = 1000;
  static const int defaultTargetWeight = 250;

  // Schedule time step (minutes)
  static const int scheduleTimeStep = 15;

  // Supabase table names
  static const String tableDevices = 'devices';
  static const String tableDeviceState = 'device_state';
  static const String tableSchedules = 'schedules';
  static const String tableCommands = 'commands';
  static const String tableAlerts = 'alerts';

  // Supabase environment variable names
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  AppConstants._();
}
