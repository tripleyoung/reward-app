import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

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
  final _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  bool _isEmailVerified = false;
  String? _error;

  Timer? _timer;
  int _timeLeft = 0; // 남은 시간(초)
  static const int _validityDuration = 300; // 5분 = 300초

  @override
  void dispose() {
    // 타이머 정리
    _timer?.cancel();

    // 컨트롤러들 정리
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _verificationCodeController.dispose();

    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _validityDuration;
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

  Future<void> _handleEmailSend() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _error = "이메일을 입력해 주세요.";
      });
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      print('[DEBUG] Sending email to: ${_emailController.text}');

      final response = await _dio.post(
        '/members/verify/send',
        queryParameters: {
          'email': _emailController.text,
        },
      );

      print('[DEBUG] Response received:');
      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Response data: ${response.data}');

      // null check 추가
      if (response.data == null) {
        print('[DEBUG] Response data is null');
        throw Exception('Response data is null');
      }

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => null,
      );

      print('[DEBUG] API Response:');
      print('[DEBUG] Success: ${apiResponse.success}');
      print('[DEBUG] Message: ${apiResponse.message}');

      if (mounted) {
        // success 여부와 관계없이 서버에서 온 메시지를 표시
        final message = apiResponse.message ?? '인증 코드가 발송되었습니다.';
        print('[DEBUG] Showing snackbar with message: $message');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: apiResponse.success ? Colors.green : Colors.red,
          ),
        );

        // 에러 메시지는 success가 false일 때만 설정
        if (!apiResponse.success) {
          setState(() {
            _error = message;
          });
        }

        if (apiResponse.success) {
          _startTimer(); // 타이머 시작
        }
      }
    } on DioException catch (e) {
      print('[DEBUG] DioException caught:');
      print('[DEBUG] Error type: ${e.type}');
      print('[DEBUG] Error message: ${e.message}');
      print('[DEBUG] Response data: ${e.response?.data}');

      if (mounted) {
        final errorMessage = e.response?.data?['message'] ?? "이메일 발송에 실패했습니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
      print('[DEBUG] General exception caught:');
      print('[DEBUG] Error: $e');

      if (mounted) {
        const errorMessage = "이메일 발송에 실패했습니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _error = errorMessage;
        });
      }
    }
  }

  Future<void> _handleCodeVerification() async {
    try {
      final response = await _dio.post(
        '/members/verify/check',
        queryParameters: {
          'email': _emailController.text,
          'code': _verificationCodeController.text,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (json) => json as bool,
        );

        if (apiResponse.success && apiResponse.data == true) {
          setState(() {
            _isEmailVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiResponse.message ?? '이메일 인증이 완료되었습니다.')),
          );
        } else {
          setState(() {
            _error = "인증에 실패했습니다.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = "인증에 실패했습니다.";
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 인증을 완료해주세요.')),
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

        if (response.statusCode == 200) {
          final apiResponse = ApiResponse.fromJson(
            response.data,
            (json) => json as int,
          );

          if (apiResponse.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(apiResponse.message ?? '회원가입이 완료되었습니다.')),
              );
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        }
      } on DioException catch (e) {
        setState(() {
          _error = e.response?.data?['message'] ?? "회원가입에 실패했습니다.";
        });
      } catch (e) {
        setState(() {
          _error = "회원가입에 실패했습니다.";
        });
      }
    }
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "리워드",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),
          FilledTextField(
            controller: _nameController,
            label: '이름',
            required: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledTextField(
                  controller: _emailController,
                  label: '이메일',
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
                  child: const Text('발송'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVerificationCodeRow(),
          const SizedBox(height: 16),
          FilledTextField(
            controller: _passwordController,
            label: '비밀번호',
            obscureText: true,
            required: true,
          ),
          const SizedBox(height: 16),
          FilledTextField(
            controller: _nicknameController,
            label: '닉네임',
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
            child: const Text('가입하기'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: kElementHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: TextButton(
              onPressed: () {},
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
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sign up with Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('이미 가입되어 있나요?'),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  '로그인하기',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2024 Reward - All Rights Reserved.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCodeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FilledTextField(
            controller: _verificationCodeController,
            label: '인증번호',
            required: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: _handleCodeVerification,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  minimumSize: Size.fromHeight(kElementHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                child: const Text('인증확인'),
              ),
              if (_timeLeft > 0) ...[
                const SizedBox(height: 4),
                Text(
                  _timeLeftString,
                  textAlign: TextAlign.center,
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
    );
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
                child: Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.people,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          label: Text(
                            '영업자 로그인',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildSignInForm(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildSignInForm(),
          ),
        ),
      );
    }
  }
}
