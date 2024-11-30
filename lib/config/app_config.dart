import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // 환경변수로 설정된 URL이 있으면 그것을 우선 사용
  static String get apiBaseUrl {
    // 환경변수에서 URL 확인
    final envUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    // 환경변수에 URL이 설정되어 있다면 그것을 사용
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 웹 환경이면 localhost 사용
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }

    // 모바일 환경일 경우
    const bool usePhysicalDevice = false; // 실제 기기 테스트시 true
    
    if (usePhysicalDevice) {
      return 'http://192.168.1.xxx:8080/api/v1'; // 개발 컴퓨터의 IP 주소로 변경
    }
    
    // 에뮬레이터/시뮬레이터 환경
    return Platform.isAndroid 
        ? 'http://10.0.2.2:8080/api/v1'
        : 'http://localhost:8080/api/v1';
  }

  static String get redirectUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/oauth2/redirect';  // 웹용 리다이렉트 URL
    }
    return 'com.outsider.reward://oauth2redirect';  // 모바일용 리다이렉트 URL
  }

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'credentials': 'include',  // 쿠키 포함
  };
} 