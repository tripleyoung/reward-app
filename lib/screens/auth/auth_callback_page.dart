import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    final dio = DioService.getInstance(context);
    try {
      final response = await dio.get('/members/me');
      if (response.statusCode == 200) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setAuthenticated(true);
        
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/home');
      } else {
        _handleAuthError();
      }
    } catch (e) {
      developer.log('Auth check failed: $e');
      _handleAuthError();
    }
  }

  void _handleAuthError() {
    final currentLocale = Localizations.localeOf(context).languageCode;
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