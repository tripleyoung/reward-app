import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  final _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  void _handleLogin() async {
    setState(() {
      _error = null;
    });

    try {
      final response = await _dio.post('/members/login', data: {
        "email": _emailController.text,
        "password": _passwordController.text,
      });

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success) {
          // TODO: Store tokens in secure storage
          final tokens = apiResponse.data;
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          setState(() {
            _error = apiResponse.message ?? "로그인에 실패했습니다.";
          });
        }
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message'] ?? "로그인에 실패했습니다.";
      });
    } catch (e) {
      setState(() {
        _error = "로그인에 실패했습니다.";
      });
    }
  }

  Widget _buildLoginForm() {
    return Column(
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
          controller: _emailController,
          label: '이메일',
          keyboardType: TextInputType.emailAddress,
          required: true,
        ),
        const SizedBox(height: 16),
        FilledTextField(
          controller: _passwordController,
          label: '비밀번호',
          obscureText: true,
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
          onPressed: _handleLogin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
            minimumSize: Size.fromHeight(kElementHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
          ),
          child: const Text('로그인'),
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
                  'Sign in with Google',
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
            const Text('회원가입이 안되어 있나요?'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              child: Text(
                '가입하기',
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
                child: _buildSideMenu(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildLoginForm(),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildLoginForm(),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 