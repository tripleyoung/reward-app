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

  static String get apiBaseUrl {
    if (_environment == Environment.dev && !kIsWeb) {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080'; // 안드로이드 에뮬레이터용
      }
    }

    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );
  }

  static String get apiPath => '/api/v1';

  // Google OAuth
  static String get googleWebClientId => const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue:
            '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com',
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

  static String get rewardAppUrl => _environment == Environment.prod
      ? 'https://app.reward-factory.shop'
      : 'http://localhost:46151';
}
