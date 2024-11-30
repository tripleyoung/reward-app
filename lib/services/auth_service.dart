import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // 토큰 저장
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 리프레시 토큰 가져오기
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
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