import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:flutter/material.dart';

class DioService {
  static Dio getInstance(BuildContext context) {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {
        'Accept-Language': Localizations.localeOf(context).languageCode,
      },
    ));

    // 인터셉터 추가
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 요청시 현재 locale 정보를 헤더에 추가
        options.headers['Accept-Language'] = Localizations.localeOf(context).languageCode;
        return handler.next(options);
      },
    ));

    return dio;
  }
} 