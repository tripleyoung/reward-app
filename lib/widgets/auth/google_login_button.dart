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

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      if (kIsWeb) {
        final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api/v1', '');
        final currentLocale = Localizations.localeOf(context).languageCode;
        final authUrl = '$baseUrl/oauth2/authorization/google?locale=$currentLocale';
        
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

        await googleSignIn.signOut();
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        
        if (account != null) {
          final GoogleSignInAuthentication auth = await account.authentication;
          
          final dio = DioService.getInstance(context);
          try {
            final response = await dio.post('/api/v1/members/oauth2/google/callback', data: {
              'idToken': auth.idToken,
            });

            if (response.statusCode == 200) {
              final currentLocale = Localizations.localeOf(context).languageCode;
              context.go('/$currentLocale/home');
            }
          } catch (e) {
            print('API Error: $e');
            throw e;
          }
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
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