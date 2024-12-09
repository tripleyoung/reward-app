import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import '../../widgets/common/language_dropdown.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../widgets/auth/google_login_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../../models/token_dto.dart'; // 경로 수정
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../utils/responsive.dart';

class LoginPage extends StatefulWidget {
  final Locale? locale;

  const LoginPage({super.key, this.locale});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false; // 이메일/비밀번호 저장 상태
  late Dio _dio;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // 저장된 로그인 정보 불러오기
  }

  // 저장된 로그인 정보 불러오기
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  // 로그인 정보 저장
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', _emailController.text);
      await prefs.setString('savedPassword', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dio = DioService.instance;
  }

  Future<void> _handleLogin() async {
    try {
      final response = await _dio.post(
        '/members/login',
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      if (mounted && apiResponse.success && apiResponse.data != null) {
        await _saveCredentials(); // 로그인 성공 시 credentials 저장

        final tokenDto = apiResponse.data!;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setTokens(
          accessToken: tokenDto.accessToken,
          refreshToken: tokenDto.refreshToken,
        );

        if (mounted) {
          final currentLocale = Localizations.localeOf(context).languageCode;
          context.go('/$currentLocale/home');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      // 에러 처리는 dio_service에서 처리
    }
  }

  Future<void> _handleBusinessLogin() async {
    final businessUrl = Uri.parse(AppConfig.businessDomain);
    if (kIsWeb) {
      // 웹에서는 현재 창에서 이동
      await launchUrl(businessUrl, webOnlyWindowName: '_self');
    } else {
      // 다른 플랫폼에서는 외부 브라우저로 열기
      await launchUrl(
        businessUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _buildLoginForm() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        FilledTextField(
          controller: _emailController,
          label: l10n.emailLabel,
          keyboardType: TextInputType.emailAddress,
          required: true,
        ),
        const SizedBox(height: 16),
        FilledTextField(
          controller: _passwordController,
          label: l10n.passwordLabel,
          obscureText: true,
          required: true,
        ),
        const SizedBox(height: 8),
        // 이메일/비밀번호 저장 ��크박스
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Text(
              l10n.rememberCredentials,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _handleLogin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
            minimumSize: const Size.fromHeight(kElementHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
          ),
          child: Text(l10n.loginButton),
        ),
        const SizedBox(height: 16),
        const GoogleLoginButton(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.noAccount),
            TextButton(
              onPressed: () {
                final currentLocale =
                    Localizations.localeOf(context).languageCode;
                print('현재 로케일: $currentLocale');
                print('이동할 경로: /$currentLocale/signin');
                context.go('/$currentLocale/signin');
              },
              child: Text(
                l10n.signUpButton,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSideMenu() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context).appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            AppLocalizations.of(context).loginTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).loginDescription,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드 메뉴 (태블릿 이상에서만 표시)
          if (!isMobile(context))
            Expanded(
              flex: isDesktop(context) ? 2 : 1,
              child: Container(
                color: Colors.green.shade600,
                child: Stack(
                  children: [
                    _buildSideMenu(),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: OutlinedButton(
                        onPressed: _handleBusinessLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.business, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).salesLogin,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 로그인 폼
          Expanded(
            flex: isDesktop(context) ? 1 : 2,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  // 모바일에서만 표시되는 앱바
                  if (isMobile(context))
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.business),
                          onPressed: _handleBusinessLogin,
                        ),
                        actions: const [
                          LanguageDropdown(),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),

                  // 언어 선택 드롭다운 (태블릿 이상에서만)
                  if (!isMobile(context))
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const LanguageDropdown(),
                      ),
                    ),

                  // 로그인 폼
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 32),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isMobile(context) ? double.infinity : 400,
                        ),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _sub?.cancel();
    super.dispose();
  }
}
