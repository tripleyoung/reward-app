import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<void> setTokens({String? accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _isAuthenticated = accessToken != null;
    
    // SharedPreferences에도 저장
    if (accessToken != null && refreshToken != null) {
      await AuthService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _isAuthenticated = false;
    await AuthService.logout();
    notifyListeners();
  }

  // 초기 상태 로드
  Future<void> loadAuthState() async {
    final token = await AuthService.getToken();
    final refreshToken = await AuthService.getRefreshToken();
    _accessToken = token;
    _refreshToken = refreshToken;
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> setAuthenticated(bool value) async {
    _isAuthenticated = value;
    notifyListeners();
  }
} 