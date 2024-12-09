import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/token_dto.dart';
import '../config/app_config.dart';
import '../services/dio_service.dart';

class AuthProvider extends ChangeNotifier {
  final BuildContext context;
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  Timer? _refreshTimer;
  Map<String, dynamic>? _userInfo;
  bool _isInitialized = false;

  AuthProvider(this.context);

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isInitialized => _isInitialized;

  UserInfo? get currentUser =>
      _userInfo != null ? UserInfo.fromJson(_userInfo!) : null;

  Future<UserInfo?> get user async {
    if (!_isAuthenticated) return null;
    if (_userInfo == null) {
      if (kDebugMode) {
        print('User info is null, fetching from server...');
      }
      return await fetchUserInfo();
    }
    return UserInfo.fromJson(_userInfo!);
  }

  Future<UserInfo?> fetchUserInfo() async {
    if (!_isAuthenticated) return null;

    try {
      final dio = DioService.instance;
      final response = await dio.get('/members/me');
      print('response: ${response.data}');
      if (kDebugMode) {
        print('fetchUserInfo response: ${response.data}');
      }

      if (response.data['success']) {
        final userData = response.data['data'] as Map<String, dynamic>;
        _userInfo = userData;
        notifyListeners();
        return UserInfo.fromJson(userData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user info: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    }
    return null;
  }

  void startTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
        const Duration(minutes: 15), // 15분 만료 토큰의 경우
        (_) => refreshAuthToken());
  }

  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final dio = DioService.instance;

      final response = await dio
          .post('/members/refresh', data: {'refreshToken': _refreshToken});

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await setTokens(
            accessToken: apiResponse.data?.accessToken,
            refreshToken: apiResponse.data?.refreshToken);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      await logout();
    }
    return false;
  }

  Future<void> setTokens({String? accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _isAuthenticated = accessToken != null;

    if (accessToken != null) {
      startTokenRefreshTimer(); // 토큰 설정 시 자동 갱신 시작
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
    final currentRefreshToken = _refreshToken;
    _refreshTimer?.cancel();

    // 서버에 로그아웃 요청
    if (currentRefreshToken != null) {
      try {
        final dio = DioService.instance;
        await dio.post('/members/logout',
            data: {'refreshToken': currentRefreshToken});
      } catch (e) {
        if (kDebugMode) {
          print('Logout error: $e');
        }
      }
    }

    // 로컬 상태 초기화
    _accessToken = null;
    _refreshToken = null;
    _isAuthenticated = false;
    _userInfo = null;

    await AuthService.logout();
    notifyListeners();
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
    _isInitialized = true;
    notifyListeners();
  }

  // 별도의 초기화 메서드로 분리
  Future<void> initializeUserInfo() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_isAuthenticated && _userInfo == null) {
      try {
        final userInfo = await fetchUserInfo();
        if (userInfo != null) {
          _userInfo = userInfo.toJson();
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing user info: $e');
        }
      }
    }
  }
}

class UserInfo {
  final String userId;
  final String userName;
  final String email;
  final String role;
  final String? nickname;
  final String? profileImage;
  final DateTime? createdAt;

  UserInfo({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    this.nickname,
    this.profileImage,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Parsing UserInfo from JSON: $json');
    }
    return UserInfo(
      userId: json['id']?.toString() ?? '',
      userName: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': userName,
      'email': email,
      'role': role,
      'nickname': nickname,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
