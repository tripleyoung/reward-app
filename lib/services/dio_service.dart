import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';

class DioService {
  static Dio? _instance;
  static BuildContext? _context;
  static int _refreshAttempts = 0;  // 토큰 갱신 시도 횟수
  static const int _maxRefreshAttempts = 3;  // 최대 시도 횟수
  static bool _isRefreshing = false;  // 현재 갱신 중인지 여부

  // 토스트 메시지 표시 유틸리티 메서드
  static void _showToast(BuildContext context, String message, bool success) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
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
  static Future<void> _handleTokens(RequestOptions options, AuthProvider authProvider) async {
    final accessToken = authProvider.accessToken;

    // 액세스 토큰은 항상 전송 (refresh 엔드포인트 제외)
    if (accessToken != null && !options.path.endsWith('/members/refresh')) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 리프레시 토큰은 토큰 갱신 요청시에만 전송 (요청 바디로)
    if (options.path.endsWith('/members/refresh')) {
      final refreshToken = authProvider.refreshToken;
      if (refreshToken != null) {
        options.data = {'refreshToken': refreshToken};
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

  static void init(BuildContext context) {
    _context = context;
  }

  static Dio get instance {
    if (_instance == null) {
      if (kDebugMode) {
        print('Creating new Dio instance');
      }

      if (_context == null) {
        throw Exception('DioService not initialized. Call DioService.init() first.');
      }

      final authProvider = Provider.of<AuthProvider>(_context!, listen: false);

      String? currentLocale;
      try {
        currentLocale = Localizations.localeOf(_context!).languageCode;
      } catch (e) {
        currentLocale = 'ko';
      }

      _instance = Dio(
        BaseOptions(
          baseUrl: '${AppConfig.apiBaseUrl}${AppConfig.apiPath}',
          contentType: 'application/json',
          headers: {
            ..._getDefaultHeaders(),
            'Accept-Language': currentLocale ?? 'ko',
          },
          followRedirects: true,
          maxRedirects: 5,
          extra: {'withCredentials': true},
          validateStatus: (status) => status! < 400,
        ),
      );

      _instance!.interceptors.clear();
      _instance!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            _logRequest(options);
            await _handleTokens(options, authProvider);
            return handler.next(options);
          },
          onResponse: (response, handler) async {
            _logResponse(response);
            _handleApiResponse(response, _context!);
            return handler.next(response);
          },
          onError: (error, handler) async {
            _logDioError(error);

            if (error.response?.statusCode == 401 && 
                !error.requestOptions.path.endsWith('/members/refresh')) {
              
              // 갱신 시도 횟수와 현재 상태 체크
              if (_refreshAttempts >= _maxRefreshAttempts || _isRefreshing) {
                _refreshAttempts = 0;  // 횟수 초기화
                return handler.next(error);
              }

              _isRefreshing = true;
              _refreshAttempts++;

              try {
                final isRefreshed = await authProvider.refreshAuthToken();
                
                if (isRefreshed) {
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {...error.requestOptions.headers},
                  );
                  opts.headers!['Authorization'] = 'Bearer ${authProvider.accessToken}';

                  final response = await _instance!.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  _refreshAttempts = 0;  // 성공시 횟수 초기화
                  return handler.resolve(response);
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error during token refresh: $e');
                }
              } finally {
                _isRefreshing = false;
              }
            }

            return handler.next(error);
          },
        ),
      );
    }

    return _instance!;
  }

  // 기본 헤더 설정
  static Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'ko',
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
