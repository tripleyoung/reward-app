import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';

class DioService {
  // 쿠키 관련 유틸리티 메서드
  static String? getCookie(String name) {
    if (!kIsWeb) return null;
    
    final cookies = document.cookie?.split(';');
    if (cookies == null) return null;
    
    for (var cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts[0] == name) return parts[1];
    }
    return null;
  }

  // 토스트 메시지 표시 유틸리티 메서드
  static void _showToast(BuildContext context, String message, bool success) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  // API 응답 로깅 유틸리티 메서드
  static void _logApiCall(String type, dynamic data, {String? uri, int? statusCode}) {
    if (kDebugMode) {
      final message = StringBuffer('\n----------------------------------------\n');
      message.write('[$type] ');
      if (uri != null) message.write('URI: $uri\n');
      if (statusCode != null) message.write('Status: $statusCode\n');
      message.write('Data: $data\n');
      message.write('----------------------------------------');
      debugPrint(message.toString());
    }
  }

  // 에러 로깅 유틸리티 메서드
  static void _logError(String message, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      final errorMessage = StringBuffer('\n========================================\n');
      errorMessage.write('🚨 ERROR: $message\n');
      errorMessage.write('Error details: $error\n');
      if (stackTrace != null) {
        errorMessage.write('StackTrace: \n$stackTrace\n');
      }
      errorMessage.write('========================================');
      debugPrint(errorMessage.toString());
      
      // 스택트레이스를 별도로 출력
      if (stackTrace != null) {
        print('Full stack trace:');
        print(stackTrace);
      }
    }
  }

  // 성공/실패 로깅
  static void _logResult(bool success, String? message) {
    if (kDebugMode) {
      final icon = success ? '✅' : '❌';
      final status = success ? 'Success' : 'Failure';
      debugPrint('\n$icon $status: $message');
    }
  }

  // Dio 인스턴스 생성 및 설정
  static Dio getInstance(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
        headers: _getDefaultHeaders(),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status! < 500,
        extra: {'withCredentials': true},
      ),
    );

    dio.interceptors.add(_createInterceptor(context));
    return dio;
  }

  // 기본 헤더 설정
  static Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      'Access-Control-Allow-Credentials': 'true',
    };
  }

  // 인터셉터 생성
  static InterceptorsWrapper _createInterceptor(BuildContext context) {
    return InterceptorsWrapper(
      onRequest: (options, handler) => _handleRequest(options, handler),
      onResponse: (response, handler) => _handleResponse(response, handler, context),
      onError: (error, handler) => _handleError(error, handler, context),
    );
  }

  // 요청 처리
  static Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kIsWeb) {
      final accessToken = getCookie('accessToken');
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    if (options.method == 'OPTIONS') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200));
    }

    _logApiCall('Request', {
      'method': options.method,
      'headers': options.headers,
      'data': options.data,
      'queryParameters': options.queryParameters,
    }, uri: options.uri.toString());
    
    return handler.next(options);
  }

  // 응답 처리
  static Future<void> _handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
    BuildContext context,
  ) async {
    _logApiCall('Response', response.data, 
      uri: response.realUri.toString(), 
      statusCode: response.statusCode
    );

    // API 응답 처리
    if (response.data != null) {
      String? message;
      bool success = false;

      if (response.data is Map<String, dynamic>) {
        final apiResponse = response.data as Map<String, dynamic>;
        message = apiResponse['message'] as String?;
        success = apiResponse['success'] as bool? ?? false;
        
        // 성공/실패 로그 출력
        if (success) {
          developer.log('✅ Success: $message');
        } else {
          developer.log('❌ Failure: $message');
        }
      } else if (response.data is String) {
        message = response.data;
        success = response.statusCode == 200;
        developer.log(success ? '✅ Success: $message' : '❌ Failure: $message');
      }

      if (message != null && message.isNotEmpty) {
        _showToast(context, message, success);
      }
    }

    _handleRedirect(response, context);
    return handler.next(response);
  }

  // 리다이렉트 처리
  static void _handleRedirect(Response response, BuildContext context) {
    if (response.statusCode == 302) {
      final location = response.headers['location']?.first;
      if (location != null) {
        final uri = Uri.parse(location);
        if (uri.path == '/home') {
          GoRouter.of(context).go(uri.path, extra: uri.queryParameters);
        }
      }
    }
  }

  // 에러 처리
  static Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
    BuildContext context,
  ) async {
    final errorMessage = _extractErrorMessage(error);
    
    // 에러 로깅
    _logError(
      errorMessage,
      error,
      error.stackTrace,
    );

    if (errorMessage.isNotEmpty) {
      _showToast(context, errorMessage, false);
    }

    return handler.next(error);
  }

  // 에러 메시지 추출
  static String _extractErrorMessage(DioException error) {
    if (error.response?.data == null) {
      return error.message ?? 'Unknown error';
    }

    final errorData = error.response!.data;
    if (errorData is Map<String, dynamic>) {
      return (errorData['message'] ?? 
              errorData['error'] ?? 
              error.message ?? 
              'Unknown error').toString();
    } else if (errorData is String) {
      return errorData;
    }
    
    return error.message ?? 'Unknown error';
  }
}
