import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/common/language_dropdown.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  final Locale? locale;
  
  const SignInPage({super.key, this.locale});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  String? _error;
  Timer? _timer;
  int _timeLeft = 0;
  final _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  bool _isEmailVerified = false;

  Widget _buildSideMenu() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.signUpTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '새로운 계정을 만들어 리워드의 다양한 서비스를 이용해보세요.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.signUpTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),
          FilledTextField(
            controller: _nameController,
            label: AppLocalizations.of(context)!.nameLabel,
            required: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  required: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _handleEmailSend,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    minimumSize: Size.fromHeight(kElementHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.verifyEmailButton),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledTextField(
                  controller: _verificationCodeController,
                  label: AppLocalizations.of(context)!.verificationCodeLabel,
                  required: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: _handleCodeVerification,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        minimumSize: Size.fromHeight(kElementHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.verifyCodeButton),
                    ),
                    if (_timeLeft > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        _timeLeftString,
                        style: TextStyle(
                          color: _timeLeft < 60 ? Colors.red : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledTextField(
            controller: _passwordController,
            label: AppLocalizations.of(context)!.passwordLabel,
            obscureText: true,
            required: true,
          ),
          const SizedBox(height: 16),
          FilledTextField(
            controller: _nicknameController,
            label: AppLocalizations.of(context)!.nicknameLabel,
            required: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 0),
              minimumSize: Size.fromHeight(kElementHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.signUpButton),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailSend() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _error = AppLocalizations.of(context)!.emailRequired;
      });
      return;
    }

    try {
      final response = await _dio.post('/members/verify/send', 
        queryParameters: {
          'email': _emailController.text,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResponse.message ?? AppLocalizations.of(context)!.emailSendSuccess),
            backgroundColor: apiResponse.success ? Colors.green : Colors.red,
          ),
        );

        if (apiResponse.success) {
          _startTimer();  // 타이머 시작
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMessage = e.response?.data?['message'] ?? AppLocalizations.of(context)!.emailSendFail;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCodeVerification() async {
    try {
      final response = await _dio.post('/members/verify/check',
        queryParameters: {
          'email': _emailController.text,
          'code': _verificationCodeController.text,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (mounted) {
        if (apiResponse.success && apiResponse.data == true) {
          setState(() {
            _isEmailVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.emailVerifySuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.emailVerifyFail),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.emailVerifyFail),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emailVerificationRequired),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final response = await _dio.post('/members/signup', data: {
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "nickname": _nicknameController.text,
        });

        final apiResponse = ApiResponse.fromJson(
          response.data,
          (json) => json as int,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResponse.message ?? AppLocalizations.of(context)!.signupSuccess),
            ),
          );

          if (apiResponse.success) {
            final currentLocale = Localizations.localeOf(context).languageCode;
            context.go('/$currentLocale/login');
          }
        }
      } on DioException catch (e) {
        setState(() {
          _error = e.response?.data?['message'] ?? AppLocalizations.of(context)!.signupFail;
        });
      } catch (e) {
        setState(() {
          _error = AppLocalizations.of(context)!.signupFail;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 300; // 5분
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _timeLeftString {
    final minutes = (_timeLeft / 60).floor();
    final seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWebLayout = MediaQuery.of(context).size.width > 768;

    if (isWebLayout) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.green.shade600,
                child: _buildSideMenu(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Stack(
                  children: [
                    // 언어 선택 드롭다운
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
                    // 기존 폼
                    Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _buildSignInForm(),
                          ),
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
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final currentLocale = Localizations.localeOf(context).languageCode;
              context.go('/$currentLocale/login');
            },
          ),
          actions: [
            const LanguageDropdown(),
            const SizedBox(width: 8),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildSignInForm(),
            ),
          ),
        ),
      );
    }
  }
}
