import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'providers/locale_provider.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = const String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.setEnvironment(env == 'prod' ? Environment.prod : Environment.dev);

  if (kDebugMode) {
    print('\n=== App Configuration ===');
    print('🌍 Environment: ${env == 'prod' ? 'Production' : 'Development'}');
    print('🌐 Backend URL: ${AppConfig.apiBaseUrl}${AppConfig.apiPath}');
    print('========================\n');
  }

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp.router(
          routerConfig: router,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('ko', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
        );
      },
    );
  }
}
