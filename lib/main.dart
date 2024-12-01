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

void main() {
  if (kDebugMode) {
    print('🐛 Debug mode is active');
    print('==================================================');
    print('🔍 VM Service URL will appear above');
    print('==================================================');
    
    developer.registerExtension('ext.myFlutterApp', (method, params) async {
      return developer.ServiceExtensionResponse.result('{"success": true}');
    });
    
    print('🚀 App starting...');
  }
  
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('📡 Flutter binding initialized');
  }

  final authProvider = AuthProvider();
  authProvider.loadAuthState().then((_) {
    if (kDebugMode) {
      print('🔐 Auth state loaded');
    }
  });

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
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
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
      ),
    );
  }
}
