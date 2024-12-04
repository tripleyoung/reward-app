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
      if (kDebugMode) print('Attempting logout');
      
      final dio = DioService.getInstance(context);
      await dio.post('/members/logout');
      
      if (kDebugMode) print('Server logout successful');

      if (context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();

        if (kDebugMode) {
          print('Local logout completed');
          print('Auth state: ${authProvider.isAuthenticated}');
        }

        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      // 서버 에러가 발생해도 로컬 로그아웃은 진행
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
        title: Text(AppLocalizations.of(context).appTitle),
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
