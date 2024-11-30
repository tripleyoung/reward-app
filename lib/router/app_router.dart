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
  initialLocation: '/ko/login',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/:lang',
      builder: (context, state) => const Scaffold(),
      redirect: (context, state) {
        final isLoggedIn = false;
        final lang = state.pathParameters['lang'] ?? 'ko';

        if (isLoggedIn && state.matchedLocation == '/$lang/signin') {
          return '/$lang/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => LoginPage(
            locale: Locale(state.pathParameters['lang'] ?? 'ko'),
          ),
        ),
        GoRoute(
          path: 'signin',
          builder: (context, state) => SignInPage(
            locale: Locale(state.pathParameters['lang'] ?? 'ko'),
          ),
        ),
        GoRoute(
          path: 'home',
          builder: (context, state) {
            final lang = state.pathParameters['lang'] ?? 'ko';
            return HomePage(locale: Locale(lang));
          },
        ),
        GoRoute(
          path: 'auth/callback',
          builder: (context, state) {
            final lang = state.pathParameters['lang'] ?? 'ko';
            return const AuthCallbackPage();
          },
        ),
      ],
    ),
  ],
); 