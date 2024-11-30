import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

enum Environment {
  dev,
  prod,
}

class AppConfig {
  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get apiBaseUrl {
    if (kIsWeb) {
      return _getWebBaseUrl();
    } else {
      return _getMobileBaseUrl();
    }
  }

  static String _getWebBaseUrl() {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:8080/api/v1';
      case Environment.prod:
        return 'https://api.reward.com/api/v1';
    }
  }

  static String _getMobileBaseUrl() {
    switch (_environment) {
      case Environment.dev:
        return Platform.isAndroid 
            ? 'http://10.0.2.2:8080/api/v1'  // Android 에뮬레이터
            : 'http://localhost:8080/api/v1'; // iOS 시뮬레이터
      case Environment.prod:
        return 'https://api.reward.com/api/v1';
    }
  }

  static String get googleClientId {
    if (kIsWeb) {
      return _getWebGoogleClientId();
    } else {
      return _getMobileGoogleClientId();
    }
  }

  static String _getWebGoogleClientId() {
    switch (_environment) {
      case Environment.dev:
        return '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
      case Environment.prod:
        return 'your-prod-web-client-id.apps.googleusercontent.com';
    }
  }

  static String _getMobileGoogleClientId() {
    switch (_environment) {
      case Environment.dev:
        return '133048024494-s3hl3npre9hrmqeokp4pqp36me559o50.apps.googleusercontent.com';
      case Environment.prod:
        return 'your-prod-android-client-id.apps.googleusercontent.com';
    }
  }

  static String get redirectUrl {
    if (kIsWeb) {
      switch (_environment) {
        case Environment.dev:
          return 'http://localhost:3000/oauth2/redirect';
        case Environment.prod:
          return 'https://reward.com/oauth2/redirect';
      }
    } else {
      return 'com.outsider.reward://oauth2redirect';
    }
  }
} 