import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:flutter/material.dart';

class DioService {
  static Dio getInstance(BuildContext context) {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        extra: {
          'withCredentials': true,
        },
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (kReleaseMode) {
              options.extra['withCredentials'] = true;
            }
            return handler.next(options);
          },
        ),
      );
  }
} 