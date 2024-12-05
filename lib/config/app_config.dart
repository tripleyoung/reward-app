import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
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

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static String get apiBaseUrl {
    if (kIsWeb) {
      return _getWebBaseUrl();
    } else if (isDesktop) {
      return _getDesktopBaseUrl();
    } else {
      return _getMobileBaseUrl();
    }
  }

  static String _getDesktopBaseUrl() {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.prod:
        return 'https://backend.reward-factory.shop:8765';
    }
  }

  static String _getWebBaseUrl() {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.prod:
        return 'https://backend.reward-factory.shop:8765';
    }
  }

  static String _getMobileBaseUrl() {
    switch (_environment) {
      case Environment.dev:
        return Platform.isAndroid
            ? 'http://10.0.2.2:8080'
            : 'http://localhost:8080';
      case Environment.prod:
        return 'https://backend.reward-factory.shop:8765';
    }
  }

  static String get apiPath {
    return '/api/v1';
  }

  static const String googleWebClientId =
      '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
  static const String googleAndroidClientId =
      '133048024494-s3hl3npre9hrmqeokp4pqp36me559o50.apps.googleusercontent.com';

  static String get googleClientId {
    if (kIsWeb) return googleWebClientId;
    if (Platform.isAndroid) return googleAndroidClientId;
    return googleWebClientId; // 기본값
  }

  static String _getWebGoogleClientId() {
    switch (_environment) {
      case Environment.dev:
        return '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
      case Environment.prod:
        return '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
    }
  }

  static String _getDesktopGoogleClientId() {
    switch (_environment) {
      case Environment.dev:
        return '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
      case Environment.prod:
        return '133048024494-v9q4qimam6cl70set38o8tdbj3mcr0ss.apps.googleusercontent.com';
    }
  }

  static String _getMobileGoogleClientId() {
    switch (_environment) {
      case Environment.dev:
        return '133048024494-s3hl3npre9hrmqeokp4pqp36me559o50.apps.googleusercontent.com';
      case Environment.prod:
        return '133048024494-s3hl3npre9hrmqeokp4pqp36me559o50.apps.googleusercontent.com';
    }
  }
}
