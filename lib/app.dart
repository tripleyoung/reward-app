import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signin_page.dart';
import 'screens/home/home_page.dart';
import 'router/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Reward App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    );
  }
} 