import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' show Platform;

enum Environment {
  dev,
  prod,
}

class AppConfig {
  static Environment _environment = Environment.dev;

  static void initialize(Environment env) {
    _environment = env;
  }

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      );

  static String get apiPath => '/api/v1';

  // Google OAuth
  static String get googleWebClientId => const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '',
      );
  
  static String get googleAndroidClientId => const String.fromEnvironment(
        'GOOGLE_ANDROID_CLIENT_ID',
        defaultValue: '',
      );

  static String get googleClientId {
    if (kIsWeb) return googleWebClientId;
    if (Platform.isAndroid) return googleAndroidClientId;
    return '';
  }
}
