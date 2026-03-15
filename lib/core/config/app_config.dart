class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const bool isProduction = appEnv == 'production';
  static const bool isDevelopment = appEnv == 'development';

  static const String tokenKey = 'linker_access_token';

  static String get authRegister => '$baseUrl/auth/register';
  static String get authLogin => '$baseUrl/auth/login';
  static String get proxyLinkToConfig => '$baseUrl/proxy/link-to-config';
  static String get proxyConfigToLink => '$baseUrl/proxy/config-to-link';
  static String get proxyBulkImport => '$baseUrl/proxy/bulk-import';
  static String get history => '$baseUrl/history';
}
