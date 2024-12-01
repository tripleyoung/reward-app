import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signin_page.dart';
import '../screens/auth/auth_callback_page.dart';
import '../screens/home/home_page.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:developer' as developer;

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locale = Localizations.localeOf(context).languageCode;
    
    // 현재 경로
    final path = state.uri.path;
    
    if (kDebugMode) {
      print('🔄 Router Redirect:');
      print('Current path: $path');
      print('isAuthenticated: ${authProvider.isAuthenticated}');
      print('Locale: $locale');
    }
    
    // 인증이 필요하지 않은 경로들
    final publicPaths = [
      '/$locale/login',
      '/$locale/signin',
      '/$locale/auth/callback',
    ];

    if (kDebugMode) {
      print('Public paths: $publicPaths');
    }

    if (!authProvider.isAuthenticated) {
      // 비인증 상태에서 public path가 아닌 경로로 접근하면 로그인 페이지로
      if (!publicPaths.contains(path)) {
        if (kDebugMode) print('⏩ Redirecting to login: /$locale/login');
        return '/$locale/login';
      }
    } else {
      // 인증 상태에서 public path로 접근하면 홈으로
      if (publicPaths.contains(path)) {
        if (kDebugMode) print('⏩ Redirecting to home: /$locale/home');
        return '/$locale/home';
      }
    }

    // 루트 경로 접근 시 처리
    if (path == '/') {
      final redirectPath = authProvider.isAuthenticated ? '/$locale/home' : '/$locale/login';
      if (kDebugMode) print('⏩ Root path redirect: $redirectPath');
      return redirectPath;
    }

    if (kDebugMode) print('No redirect needed');
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final locale = Localizations.localeOf(context).languageCode;
        return '/$locale/home';
      },
    ),
    GoRoute(
      path: '/:locale/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/:locale/signin',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/:locale/home',
      builder: (context, state) => HomePage(
        locale: Locale(state.pathParameters['locale']!),
      ),
    ),
    GoRoute(
      path: '/:locale/auth/callback',
      builder: (context, state) => const AuthCallbackPage(),
    ),
  ],
); 