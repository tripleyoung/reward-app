import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  dev,
  prod,
}

class AppConfig {
  static Environment _environment = Environment.dev;

  static Future<void> initialize(Environment env) async {
    _environment = env;
    // 환경에 따른 .env 파일 로드
    await dotenv.load(fileName: env == Environment.prod ? '.env.production' : '.env.development');
  }

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  static String get apiPath => '/api/v1';

  // Google OAuth
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
  static String get googleAndroidClientId => dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '';

  static String get googleClientId {
    if (kIsWeb) return googleWebClientId;
    if (Platform.isAndroid) return googleAndroidClientId;
    return googleWebClientId; // 기본값
  }
}
