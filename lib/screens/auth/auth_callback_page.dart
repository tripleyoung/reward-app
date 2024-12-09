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
      // 1. 토큰 확인
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = AuthService.getCookie('accessToken');
      final refreshToken = AuthService.getCookie('refreshToken');

      developer.log(
          'Tokens found - Access: ${accessToken != null}, Refresh: ${refreshToken != null}');

      if (accessToken == null || refreshToken == null) {
        developer.log('No tokens found');
        _handleAuthError();
        return;
      }

      // 2. 토큰을 AuthProvider에 설정하고 완료될 때까지 대기
      await authProvider.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      developer.log('Tokens set in AuthProvider');

      // 3. 토큰이 설정된 후 사용자 정보 요청
      final dio = DioService.instance;
      final response = await dio.get('/members/me');

      if (response.statusCode == 200) {
        developer.log('User info retrieved successfully');

        // 4. 약간의 지연을 추가하여 상태 업데이트가 완료되도록 함
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          final currentLocale = Localizations.localeOf(context).languageCode;
          developer.log('Redirecting to /$currentLocale/home');
          context.go('/$currentLocale/home');
        }
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
    if (mounted) {
      final currentLocale = Localizations.localeOf(context).languageCode;
      developer.log('Redirecting to /$currentLocale/login');
      context.go('/$currentLocale/login');
    }
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
