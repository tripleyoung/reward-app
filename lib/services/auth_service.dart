import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static final _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 토큰 저장 - 보안 저장소 사용
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // 토큰 가져오기 - 보안 저장소 사용
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // 리프레시 토큰 가져오기 - 보안 저장소 사용
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  // 쿠키 삭제 메서드 추가
  static void _removeCookie(String name) {
    if (kIsWeb) {
      document.cookie = '$name=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    }
  }

  // 로그아웃 - 보안 저장소와 쿠키에서 삭제
  static Future<void> logout() async {
    if (kIsWeb) {
      // 웹에서는 쿠키 삭제
      _removeCookie('accessToken');
      _removeCookie('refreshToken');
    } else {
      // 모바일에서는 보안 저장소에서 삭제
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  // 웹에서 쿠키 가져오기
  static String? getCookie(String name) {
    if (kIsWeb) {
      final cookies = document.cookie?.split(';');
      if (cookies == null) return null;
      
      for (var cookie in cookies) {
        final keyValue = cookie.split('=');
        if (keyValue[0].trim() == name) {
          return keyValue[1];
        }
      }
    }
    return null;
  }

  // 웹에서 인증 상태 확인
  static bool isWebAuthenticated() {
    if (!kIsWeb) return false;
    
    final accessToken = getCookie('accessToken');
    final refreshToken = getCookie('refreshToken');
    
    return accessToken != null && refreshToken != null;
  }

  // 통합된 인증 확인 메서드
  static Future<bool> isAuthenticated() async {
    if (kIsWeb) {
      return isWebAuthenticated();
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey) != null;
    }
  }
} 