import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signin_page.dart';
import '../screens/home/home_page.dart';
import '../services/auth_service.dart';

final router = GoRouter(
  initialLocation: '/ko/login',
  redirect: (BuildContext context, GoRouterState state) {
    final isLoggedIn = AuthService.isLoggedIn();
    final isLoginRoute = state.matchedLocation.contains('/login');
    final isSignInRoute = state.matchedLocation.contains('/signin');
    final locale = state.pathParameters['lang'] ?? 'ko';

    if (isLoggedIn && (isLoginRoute || isSignInRoute)) {
      return '/$locale/home';
    }

    if (!isLoggedIn && !isLoginRoute && !isSignInRoute) {
      return '/$locale/login';
    }

    return null;
  },
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
); 