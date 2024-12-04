import 'dart:async';

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/token_dto.dart';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  Timer? _refreshTimer;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void startTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 14),  // 15분 만료 토큰의 경우
      (_) => _refreshTokens()
    );
  }

  Future<void> _refreshTokens() async {
    if (_refreshToken == null) return;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
      ));
      final response = await dio.post(
        '/members/refresh',
        options: Options(
          headers: {
            'Authorization-Refresh': 'Bearer $_refreshToken',
          },
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await setTokens(
          accessToken: apiResponse.data?.accessToken,
          refreshToken: apiResponse.data?.refreshToken,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      // 토큰 갱신 실패 시 로그아웃
      await logout();
    }
  }

  Future<void> setTokens({String? accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _isAuthenticated = accessToken != null;

    if (accessToken != null) {
      startTokenRefreshTimer();  // 토큰 설정 시 자동 갱신 시작
    }

    if (kDebugMode) {
      print('Setting tokens:');
      print('Access Token: ${accessToken != null}');
      print('Refresh Token: ${refreshToken != null}');
    }

    if (kDebugMode) {
      print('Auth state after setting tokens:');
      print('isAuthenticated: $_isAuthenticated');
    }

      if (accessToken != null && refreshToken != null) {
        await AuthService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();  // 타이머 중지
    _accessToken = null;
    _refreshToken = null;
    _isAuthenticated = false;

    // 웹/모바일 환경에 따른 토큰 제거
    await AuthService.logout();

    // 서버에 로그아웃 요청
    try {
      final dio = Dio(BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
        extra: {'withCredentials': true},
      ));

      await dio.post('/members/logout');
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }

    notifyListeners();
  }

  Future<void> _clearTokensFromStorage() async {
    // AuthService의 logout 메서드가 이미 플랫폼별 처리를 하므로
    // 여기서는 AuthService.logout()을 호출
    await AuthService.logout();
  }

  // 초기 상태 로드
  Future<void> loadAuthState() async {
    // 저장소에서 토큰 확인
    final token = await AuthService.getToken();
    final refreshToken = await AuthService.getRefreshToken();
    _accessToken = token;
    _refreshToken = refreshToken;
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> refreshAuthToken() async {
    if (_refreshToken == null) return;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
      ));

      final response = await dio.post(
        '/members/refresh',
        options: Options(
          headers: {
            'Authorization-Refresh': 'Bearer $_refreshToken',
          },
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        _accessToken = apiResponse.data?.accessToken;
        _refreshToken = apiResponse.data?.refreshToken;
        _isAuthenticated = true;
        await _saveTokensToStorage();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      _isAuthenticated = false;
      _accessToken = null;
      _refreshToken = null;
      await _clearTokensFromStorage();
      notifyListeners();
    }
  }

  Future<void> _saveTokensToStorage() async {
    if (!kIsWeb) {  // 웹이 아닌 경우만 저장
      if (_accessToken != null && _refreshToken != null) {
        await AuthService.saveTokens(
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
        );
      }
    }
  }



  // 앱 시작 시 호출되는 초기화 메서드
  Future<void> initializeAuth() async {
    final accessToken = await AuthService.getToken();
    final refreshToken = await AuthService.getRefreshToken();
    
    if (accessToken != null && refreshToken != null) {
      await setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    notifyListeners();
  }
}
