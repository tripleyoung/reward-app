import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const String webClientId = 'your-web-client-id';  // 웹용 클라이언트 ID
  static const String androidClientId = '133048024494-s3hl3npre9hrmqeokp4pqp36me559o50.apps.googleusercontent.com';  // 안드로이드용

  static String get googleClientId {
    if (Platform.isAndroid) {
      return androidClientId;  // 웹 클라이언트 ID가 아닌 Android 클라이언트 ID 사용
    }
    return webClientId;
  }

  static String get redirectUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/oauth2/redirect';
    }
    return 'com.outsider.reward://oauth2redirect';
  }
} 