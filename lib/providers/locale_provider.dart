import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko', '');

  Locale get locale => _locale;

  void setLocale(BuildContext context, Locale locale) {
    _locale = locale;
    
    // URL 업데이트
    final currentPath = GoRouterState.of(context).uri.path;
    final newPath = '/${locale.languageCode}${currentPath.substring(currentPath.indexOf('/', 1))}';
    context.go(newPath);
    
    notifyListeners();
  }
} 