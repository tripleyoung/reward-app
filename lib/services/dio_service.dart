import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart';
import '../config/app_config.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class DioService {
  static String? getCookie(String name) {
  if (kIsWeb) {
    final cookies = document.cookie?.split(';');
    if (cookies != null) {
      for (var cookie in cookies) {
        final parts = cookie.trim().split('=');
        if (parts[0] == name) {
          return parts[1];
        }
      }
    }
  }
  return null;
}
  static Dio getInstance(BuildContext context) {
    return Dio(
      BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Accept, Authorization',
          'Access-Control-Allow-Credentials': 'true',
        },
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) {
          return status! < 500;
        },
        extra: {
          'withCredentials': true,
        },
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (kIsWeb) {
              // 웹에서는 쿠키가 자동으로 전송됨
              // 추가적인 헤더 설정이 필요하다면 여기서 처리
            } else {
              // 모바일에서는 기존 토큰 처리 유지
               final accessToken = getCookie('accessToken');
              if (accessToken != null) {
                options.headers['Authorization'] = 'Bearer $accessToken';
              }
            }
            
            if (options.method == 'OPTIONS') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                ),
              );
            }
            developer.log('Request [${options.method}] ${options.uri}');
            developer.log('Headers: ${options.headers}');
            developer.log('Data: ${options.data}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            developer
                .log('Response [${response.statusCode}] ${response.realUri}');
            developer.log('Data: ${response.data}');
            if (response.statusCode == 302) {
              developer
                  .log('Redirect Location: ${response.headers['location']}');
              final location = response.headers['location']?.first;
              if (location != null) {
                final uri = Uri.parse(location);
                if (uri.path == '/home') {
                  GoRouter.of(context).go(uri.path, extra: uri.queryParameters);
                }
              }
            }
            return handler.next(response);
          },
          onError: (error, handler) {
            developer.log('Error: ${error.message}');
            developer.log('Response: ${error.response?.data}');
            return handler.next(error);
          },
        ),
      );
  }
}
