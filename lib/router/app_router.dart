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
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locale = Localizations.localeOf(context).languageCode;
    
    // 현재 경로에서 해시(#) 제거
    final path = state.uri.path.replaceAll('#', '');
    
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

    // 루트 경로나 locale만 있는 경로 처리
    if (path == '/' || path == '/$locale') {
      final redirectPath = authProvider.isAuthenticated ? '/$locale/home' : '/$locale/login';
      if (kDebugMode) print('⏩ Root path redirect: $redirectPath');
      return redirectPath;
    }

    // 나머지 리다이렉트 로직
    if (!authProvider.isAuthenticated) {
      if (!publicPaths.contains(path)) {
        return '/$locale/login';
      }
    } else {
      if (publicPaths.contains(path)) {
        return '/$locale/home';
      }
    }

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
      path: '/:locale',
      redirect: (context, state) {
        final locale = state.pathParameters['locale']!;
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