import 'package:flutter/material.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/common/language_dropdown.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';

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
  Timer? _timer;
  int _timeLeft = 0;
  late Dio _dio;
  bool _isEmailVerified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dio = DioService.getInstance(context);
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
            AppLocalizations.of(context).signUpTitle,
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
            AppLocalizations.of(context).signUpTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),
          FilledTextField(
            controller: _nameController,
            label: AppLocalizations.of(context).nameLabel,
            required: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context).emailLabel,
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
                    minimumSize: const Size.fromHeight(kElementHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).verifyEmailButton),
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
                  label: AppLocalizations.of(context).verificationCodeLabel,
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
                        minimumSize: const Size.fromHeight(kElementHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context).verifyCodeButton),
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
            label: AppLocalizations.of(context).passwordLabel,
            obscureText: true,
            required: true,
          ),
          const SizedBox(height: 16),
          FilledTextField(
            controller: _nicknameController,
            label: AppLocalizations.of(context).nicknameLabel,
            required: true,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 0),
              minimumSize: const Size.fromHeight(kElementHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
            ),
            child: Text(AppLocalizations.of(context).signUpButton),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailSend() async {
    if (_emailController.text.isEmpty) {
      return;
    }

    final response = await _dio.post('/members/verify/send', 
      queryParameters: {
        'email': _emailController.text,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => null,
    );

    if (mounted && apiResponse.success) {
      _startTimer();
    }
  }

  Future<void> _handleCodeVerification() async {
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

    if (mounted && apiResponse.success && apiResponse.data == true) {
      setState(() {
        _isEmailVerified = true;
        _timer?.cancel();
        _timeLeft = 0;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_isEmailVerified) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      final response = await _dio.post('/members/signup/user', data: {
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "nickname": _nicknameController.text,
      });

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json as int,
      );

      if (mounted && apiResponse.success) {
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
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
                    Positioned(
                      top: 16,
                      left: 16,
                      child: TextButton.icon(
                        onPressed: () {
                          final currentLocale = Localizations.localeOf(context).languageCode;
                          context.go('/$currentLocale/login');
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: Text(AppLocalizations.of(context).loginTitle),
                      ),
                    ),
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
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                margin: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () {
                          final currentLocale = Localizations.localeOf(context).languageCode;
                          context.go('/$currentLocale/login');
                        },
                      ),
                    ),
                    const LanguageDropdown(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSignInForm(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
