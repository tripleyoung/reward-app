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
    
    // 인증이 필요하지 않은 경로들
    final publicPaths = [
      '/$locale/login',
      '/$locale/signin',
      '/$locale/auth/callback',
    ];

    if (!authProvider.isAuthenticated) {
      // 비인증 상태에서 public path가 아닌 경로로 접근하면 로그인 페이지로
      if (!publicPaths.contains(path)) {
        return '/$locale/login';
      }
    } else {
      // 인증 상태에서 public path로 접근하면 홈으로
      if (publicPaths.contains(path)) {
        return '/$locale/home';
      }
    }

    // 루트 경로 접근 시 처리
    if (path == '/') {
      return authProvider.isAuthenticated ? '/$locale/home' : '/$locale/login';
    }

    // 그 외의 경우는 리다이렉트하지 않음
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