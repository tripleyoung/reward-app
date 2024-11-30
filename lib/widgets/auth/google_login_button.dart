import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    developer.log('Starting Google login process');
    try {
      if (kIsWeb) {
        developer.log('Web platform detected');
        final baseUrl = AppConfig.apiBaseUrl;
        final currentLocale = Localizations.localeOf(context).languageCode;
        final authUrl = '$baseUrl/oauth2/authorization/google?locale=$currentLocale';
        
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
        return;
      } else {
        developer.log('Mobile platform detected');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: AppConfig.googleClientId,
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        );

        developer.log('Attempting Google sign in');
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        
        if (account != null) {
          developer.log('Google sign in successful: ${account.email}');
          final GoogleSignInAuthentication auth = await account.authentication;
          
          if (auth.idToken != null) {
            developer.log('Got ID token, sending to backend');
            final dio = DioService.getInstance(context);
            try {
              final response = await dio.post(
                '/members/oauth2/google/callback',
                data: {'idToken': auth.idToken},
              );

              developer.log('Backend response: ${response.statusCode}');
              if (response.statusCode == 200) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.setAuthenticated(true);
                
                final currentLocale = Localizations.localeOf(context).languageCode;
                context.go('/$currentLocale/home');
              } else {
                throw Exception('Login failed: ${response.statusCode}');
              }
            } catch (e) {
              developer.log('API call error: $e');
              rethrow;
            }
          } else {
            developer.log('ID token is null');
            throw Exception('Failed to get ID token');
          }
        } else {
          developer.log('Sign in cancelled or failed');
        }
      }
    } catch (e, stackTrace) {
      developer.log('Google login error', error: e, stackTrace: stackTrace);
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
