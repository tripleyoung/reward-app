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
    developer.log('=== Checking Auth Status ===');
    final dio = DioService.getInstance(context);
    try {
      developer.log('Making request to /members/me');
      final response = await dio.get('/members/me');
      developer.log('Response received: ${response.statusCode}');
      developer.log('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        developer.log('Auth check successful');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setAuthenticated(true);
        
        final currentLocale = Localizations.localeOf(context).languageCode;
        developer.log('Redirecting to /$currentLocale/home');
        context.go('/$currentLocale/home');
      } else {
        developer.log('Auth check failed with status: ${response.statusCode}');
        _handleAuthError();
      }
    } catch (e) {
      developer.log('Auth check error:', error: e);
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