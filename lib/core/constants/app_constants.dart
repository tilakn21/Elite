class AppConstants {
  static const String appName = 'Elite Signs Management';

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // API Endpoints
  static const String baseApiUrl = 'https://api.elitesigns.com';

  // Storage Paths
  static const String imagesPath = 'images';
  static const String documentsPath = 'documents';

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String themeCacheKey = 'theme_cache';

  // Notification Channels
  static const String defaultNotificationChannelId = 'elite_signs_default';
  static const String defaultNotificationChannelName = 'Default Notifications';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
