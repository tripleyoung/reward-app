import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatelessWidget {
  final Locale locale;
  
  const HomePage({super.key, required this.locale});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final dio = DioService.getInstance(context);
      await dio.post('/members/logout');
      
      if (context.mounted) {
        // AuthProvider를 통해 로그아웃 처리
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();

        // 로그인 페이지로 이동
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      // 에러가 발생해도 로그아웃 처리
      if (context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Home',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Successfully logged in!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
} 