import 'package:flutter/foundation.dart';
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
  
  // 디버그 모드일 때 로그 레벨 설정
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        print('\x1B[33m$message\x1B[0m'); // 노란색으로 출력
      }
    };
  }
  
  final authProvider = AuthProvider();
  await authProvider.loadAuthState();

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
