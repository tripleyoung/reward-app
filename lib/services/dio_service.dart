import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';

class DioService {
  static Dio getInstance(BuildContext context) {
    final baseUrl = AppConfig.apiBaseUrl;
    final normalizedBaseUrl = baseUrl.endsWith('/api/v1')
        ? baseUrl.substring(0, baseUrl.length - 7)
        : baseUrl;

    return Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
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
          onRequest: (options, handler) {
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
