import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../services/dio_service.dart';
import '../../constants/styles.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    if (kDebugMode) print('Starting Google login process');

    try {
      if (kIsWeb) {
        if (kDebugMode) print('Web platform detected');
        final baseUrl = AppConfig.apiBaseUrl;
        final currentLocale = Localizations.localeOf(context).languageCode;
        final authUrl =
            '$baseUrl/oauth2/authorization/google?locale=$currentLocale';

        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
           webOnlyWindowName: '_self',  // 현재 창에서 열기
          );
        }
        return;
      } else {
        if (kDebugMode) print('Mobile platform detected');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: AppConfig.googleClientId,
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        );

        try {
          if (kDebugMode) print('Attempting Google sign in');
          final GoogleSignInAccount? account = await googleSignIn.signIn();

          if (kDebugMode)
            print(
                'Sign in result: ${account != null ? "Success" : "Cancelled"}');

          if (account != null) {
            if (kDebugMode) {
              print('Google sign in successful');
              print('Email: ${account.email}');
              print('Display Name: ${account.displayName}');
            }

            try {
              final GoogleSignInAuthentication auth =
                  await account.authentication;
              if (kDebugMode) print('Got authentication');

              if (auth.idToken != null) {
                if (kDebugMode) {
                  print('Got ID token');
                  print('Token length: ${auth.idToken!.length}');
                }

                final dio = DioService.getInstance(context);
                try {
                  final response = await dio.post(
                    '/members/oauth2/google/callback',
                    data: {'idToken': auth.idToken},
                  );

                  if (kDebugMode)
                    print('Backend response: ${response.statusCode}');

                  if (response.statusCode == 200) {
                    if (kDebugMode) {
                      print('Login successful, response data:');
                      print('Response data: ${response.data}');
                      print('Response type: ${response.data.runtimeType}');
                    }
                    
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    
                    final apiResponse = response.data['data'];
                    await authProvider.setTokens(
                      accessToken: apiResponse['accessToken'],
                      refreshToken: apiResponse['refreshToken'],
                    );
                    
                    if (context.mounted) {
                      if (kDebugMode) {
                        print('Auth state after login:');
                        print('isAuthenticated: ${authProvider.isAuthenticated}');
                        print('Access token present: ${authProvider.accessToken != null}');
                      }
                      
                      final currentLocale = Localizations.localeOf(context).languageCode;
                      context.go('/$currentLocale/home');
                    }
                  }
                } catch (e) {
                  if (kDebugMode) print('API call error: $e');
                  rethrow;
                }
              } else {
                if (kDebugMode) print('ID token is null');
                throw Exception('Failed to get ID token');
              }
            } catch (e) {
              if (kDebugMode) print('Authentication error: $e');
              rethrow;
            }
          } else {
            if (kDebugMode) print('Sign in cancelled by user');
          }
        } catch (e) {
          if (kDebugMode) print('Google SignIn error: $e');
          rethrow;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google login error: $e');
        if (e is Error) print('Stack trace: ${e.stackTrace}');
      }
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
