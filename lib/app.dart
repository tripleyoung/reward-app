import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signin_page.dart';
import 'screens/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reward App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => const RewardHomePage(),
      },
    );
  }
} 