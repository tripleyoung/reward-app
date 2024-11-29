import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/styles.dart';
import '../../widgets/common/filled_text_field.dart';

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

  bool _isEmailVerified = false;
  String? _error;

  Future<void> _handleEmailSend() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _error = "이메일을 입력해 주세요.";
      });
      return;
    }

    try {
      // TODO: 이메일 발송 API 연동
      // await apiClient.post('/api/v1/email/send', {
      //   email: _emailController.text,
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 코드가 발송되었습니다.')),
      );
    } catch (e) {
      setState(() {
        _error = "이메일 발송에 실패했습니다.";
      });
    }
  }

  Future<void> _handleCodeVerification() async {
    try {
      // TODO: 인증 코드 확인 API 연동
      // final response = await apiClient.post('/api/v1/email/verify', {
      //   email: _emailController.text,
      //   verifyCode: _verificationCodeController.text,
      // });
      setState(() {
        _isEmailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 인증이 완료되었습니다.')),
      );
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
        // TODO: 회원가입 API 연동
        // final response = await apiClient.post('/api/v1/user/join', {
        //   userName: _nameController.text,
        //   userId: _emailController.text,
        //   userPassword: _passwordController.text,
        //   userNickname: _nicknameController.text,
        // });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
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
          Row(
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
                child: OutlinedButton(
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
              ),
            ],
          ),
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
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          label: Text(
                            '영업자 로그인',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
} 