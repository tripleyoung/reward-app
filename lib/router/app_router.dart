import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signin_page.dart';
import '../screens/home/home_page.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/ko/login',
    routes: [
      GoRoute(
        path: '/:lang/login',
        builder: (context, state) {
          final lang = state.pathParameters['lang'] ?? 'ko';
          return LoginPage(locale: Locale(lang));
        },
      ),
      GoRoute(
        path: '/:lang/signin',
        builder: (context, state) {
          final lang = state.pathParameters['lang'] ?? 'ko';
          return SignInPage(locale: Locale(lang));
        },
      ),
      GoRoute(
        path: '/:lang/home',
        builder: (context, state) {
          final lang = state.pathParameters['lang'] ?? 'ko';
          return HomePage(locale: Locale(lang));
        },
      ),
    ],
    redirect: (context, state) {
      final lang = state.pathParameters['lang'];
      if (lang == null || !['ko', 'en'].contains(lang)) {
        final path = state.uri.path;
        return '/ko${path.substring(path.indexOf('/', 1))}';
      }
      return null;
    },
  );
} 