import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class WebStorage {
  static String? getItem(String key) {
    if (kIsWeb) {
      return html.window.localStorage[key];
    }
    return null;
  }

  static void setItem(String key, String value) {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    }
  }

  static void removeItem(String key) {
    if (kIsWeb) {
      html.window.localStorage.remove(key);
    }
  }

  static String? getCookie(String name) {
    if (!kIsWeb) return null;
    
    try {
      final cookies = html.document.cookie?.split(';');
      if (cookies == null) return null;
      
      for (var cookie in cookies) {
        final parts = cookie.trim().split('=');
        if (parts.length == 2 && parts[0].trim() == name) {
          return parts[1];
        }
      }
    } catch (e) {
      print('Error getting cookie: $e');
    }
    return null;
  }
} 