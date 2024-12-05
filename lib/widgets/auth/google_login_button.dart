import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reward/models/api_response.dart';
import 'package:reward/models/token_dto.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../services/dio_service.dart';
import '../../constants/styles.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class GoogleLoginButton extends StatelessWidget {
  final String role; // 'user', 'business', 'admin' 중 하나

  const GoogleLoginButton({super.key, this.role = 'user' // 기본값은 일반 사용자
      });

  Future<void> _handleGoogleLogin(BuildContext context) async {
    if (kDebugMode) print('Starting Google login process');

    try {
      if (kIsWeb || AppConfig.isDesktop) {
        if (kDebugMode) {
          print('${kIsWeb ? "Web" : "Desktop"} platform detected');
        }
        final authUrl = Uri.parse('${AppConfig.apiBaseUrl}/oauth2/authorization/google')
            .replace(
          queryParameters: {
            'platform': AppConfig.isDesktop ? 'desktop' : 'web',
            'role': role,
          },
        );

        if (AppConfig.isDesktop) {
          await launchUrl(
            authUrl,
            mode: LaunchMode.externalApplication,
          );
        } else if (await canLaunchUrl(authUrl)) {
          if (kIsWeb) {
            await launchUrl(
              authUrl,
              webOnlyWindowName: '_self',
            );
          } else {
            await launchUrl(
              authUrl,
              mode: LaunchMode.platformDefault,
            );
          }
        }
        return;
      } else {
        if (kDebugMode) print('Mobile platform detected');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: AppConfig.googleWebClientId,
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        );

        try {
          final GoogleSignInAccount? account = await googleSignIn.signIn();
          if (account != null) {
            final GoogleSignInAuthentication auth =
                await account.authentication;

            // Google 토큰으로 백엔드 인증
            final dio = DioService.getInstance(context);
            final response = await dio.post(
              '/members/oauth2/google/callback',
              data: {
                'idToken': auth.idToken,
                'role': role, // role 파라미터 추가
              },
            );
            if (kDebugMode) print(response.data);
            final apiResponse = ApiResponse.fromJson(
              response.data,
              (json) => TokenDto.fromJson(json as Map<String, dynamic>),
            );

            if (apiResponse.success && apiResponse.data != null) {
              final tokenDto = apiResponse.data!;
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.setTokens(
                accessToken: tokenDto.accessToken,
                refreshToken: tokenDto.refreshToken,
              );

              if (context.mounted) {
                final currentLocale =
                    Localizations.localeOf(context).languageCode;
                context.go('/$currentLocale/home');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) print('Google sign in error: $e');
          // 에러 처리
        }
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
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
            SvgPicture.asset(
              'assets/images/google.svg',
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).signInWithGoogle,
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
