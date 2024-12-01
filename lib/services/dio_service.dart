import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DioService {
  // 쿠키 관련 유틸리티 메서드
  static String? getCookie(String name) {
    if (!kIsWeb) {
      developer.log('Not a web platform, skipping cookie check');
      return null;
    }

    developer.log('Checking cookies...');
    final cookieString = document.cookie;
    developer.log('Raw cookies: $cookieString');

    if (cookieString?.isEmpty ?? true) {
      developer.log('No cookies found');
      return null;
    }

    final cookies = cookieString!.split(';');
    developer.log('Split cookies: $cookies');

    for (var cookie in cookies) {
      final parts = cookie.trim().split('=');
      developer.log('Checking cookie part: $parts');
      if (parts.length == 2 && parts[0].trim() == name) {
        developer.log('Found cookie $name: ${parts[1]}');
        return parts[1];
      }
    }

    developer.log('Cookie $name not found');
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
  static void _logApiCall(String type, dynamic data,
      {String? uri, int? statusCode}) {
    if (kDebugMode) {
      final message =
          StringBuffer('\n----------------------------------------\n');
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
      final errorMessage =
          StringBuffer('\n========================================\n');
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

  // 요청 로깅
  static void _logRequest(RequestOptions options) {
    if (kDebugMode) {
      print('\n🌐 === REQUEST START ===');
      print('📍 URL: ${options.uri}');
      print('📝 Method: ${options.method}');
      print('📤 Headers: ${options.headers}');
      print('📦 Raw Data: ${options.data}');
      print('📦 Data Type: ${options.data.runtimeType}');
    }
  }

  // 응답 로깅
  static void _logResponse(Response response) {
    if (kDebugMode) {
      print('\n📥 === RESPONSE START ===');
      print('📍 URL: ${response.realUri}');
      print('📊 Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');
    }
  }

  // 에러 로깅
  static void _logDioError(DioException error) {
    if (kDebugMode) {
      print('\n❌ === ERROR START ===');
      print('📍 URL: ${error.requestOptions.uri}');
      print('🔴 Error Type: ${error.type}');
      print('💬 Error Message: ${error.message}');
    }
  }

  // 토큰 처리
  static Future<void> _handleTokens(RequestOptions options, BuildContext context) async {
    if (kIsWeb) {
      final accessToken = getCookie('accessToken');
      if (kDebugMode) {
        print('📦 accessToken $accessToken');
      }
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;
      final refreshToken = authProvider.refreshToken;

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      if (refreshToken != null) {
        options.headers['Authorization-Refresh'] = 'Bearer $refreshToken';
      }
    }
  }

  // API 응답 처리
  static void _handleApiResponse(Response response, BuildContext context) {
    if (response.data != null) {
      String? message;
      bool success = false;

      if (response.data is Map<String, dynamic>) {
        final apiResponse = response.data as Map<String, dynamic>;
        message = apiResponse['message'] as String?;
        success = apiResponse['success'] as bool? ?? false;

        if (kDebugMode) {
          print(success ? '✅ Success: $message' : '❌ Failure: $message');
        }
      }

      if (message != null && message.isNotEmpty) {
        _showToast(context, message, success);
      }
    }
  }

  // 토큰 갱신 처리
  static Future<Response?> _handleTokenRefresh(
    DioException error,
    Dio dio,
    BuildContext context,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.refreshAuthToken();
      if (authProvider.isAuthenticated) {
        final opts = Options(
          method: error.requestOptions.method,
          headers: error.requestOptions.headers,
        );

        if (!kIsWeb && authProvider.accessToken != null) {
          opts.headers?['Authorization'] = 'Bearer ${authProvider.accessToken}';
        }

        return await dio.request(
          error.requestOptions.path,
          options: opts,
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
    }
    return null;
  }

  static Dio getInstance(BuildContext context) {
    if (kDebugMode) {
      print('Creating new Dio instance');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
        contentType: 'application/json',
        headers: _getDefaultHeaders(),
        followRedirects: true,
        maxRedirects: 5,
        extra: {'withCredentials': true},
        validateStatus: (status) => status! < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logRequest(options);
          await _handleTokens(options, context);
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _logResponse(response);
          _handleApiResponse(response, context);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logDioError(error);
          
          if (error.response?.statusCode == 401) {
            final response = await _handleTokenRefresh(error, dio, context);
            if (response != null) {
              return handler.resolve(response);
            }
          }

          final errorMessage = _extractErrorMessage(error);
          if (errorMessage.isNotEmpty) {
            _showToast(context, errorMessage, false);
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // 기본 헤더 설정
  static Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Origin, Content-Type, Accept, Authorization',
      'Access-Control-Allow-Credentials': 'true',
    };
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
              'Unknown error')
          .toString();
    } else if (errorData is String) {
      return errorData;
    }

    return error.message ?? 'Unknown error';
  }
}
