import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:reward/services/auth_service.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';
import 'dart:developer' as developer;

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    developer.log('=== Checking Auth Status ===');
    
    try {
      // 1. 먼저 토큰 확인 및 설정
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = AuthService.getCookie('accessToken');
      final refreshToken = AuthService.getCookie('refreshToken');
      
      if (accessToken == null || refreshToken == null) {
        developer.log('No tokens found');
        _handleAuthError();
        return;
      }

      // 2. 토큰을 AuthProvider에 설정
      await authProvider.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // 3. 토큰이 설정된 후 사용자 정보 요청
      final dio = DioService.getInstance(context);
      final response = await dio.get('/members/me');
      
      if (response.statusCode == 200) {
        developer.log('User info retrieved successfully');
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/home');
      } else {
        developer.log('Failed to get user info');
        _handleAuthError();
      }
    } catch (e) {
      developer.log('Auth check failed: $e');
      _handleAuthError();
    }
  }

  void _handleAuthError() {
    developer.log('Handling auth error');
    final currentLocale = Localizations.localeOf(context).languageCode;
    developer.log('Redirecting to /$currentLocale/login');
    context.go('/$currentLocale/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 