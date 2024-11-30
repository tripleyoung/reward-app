import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.html) 'dart:html' show window;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../services/dio_service.dart';
import '../../constants/styles.dart';
import 'oauth2_webview.dart';
import 'package:dio/dio.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api/v1', '');
      final currentLocale = Localizations.localeOf(context).languageCode;
      
      // locale 파라미터 추가
      final authUrl = '$baseUrl/oauth2/authorization/google?locale=$currentLocale';
      
      if (kIsWeb) {
        window.location.href = authUrl;
      } else {
        // 모바일에서는 웹뷰로 열기
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OAuth2WebView(
              url: authUrl,
              redirectUrl: AppConfig.redirectUrl,
            ),
          ),
        );

        if (result != null) {
          final currentLocale = Localizations.localeOf(context).languageCode;
          context.go('/$currentLocale/home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginFail),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kElementHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: TextButton(
        onPressed: () => _handleGoogleLogin(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/images/google.svg',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.signInWithGoogle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 