import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Locale? locale;
  
  const HomePage({super.key, this.locale});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('홈 페이지'),
      ),
    );
  }
} 