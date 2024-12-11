import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? _error;
  int _point = 0;
  String _userNickname = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      // 유저 정보는 AuthProvider에서 가져오기
      final authProvider = context.read<AuthProvider>();
      final user = await authProvider.user;
      
      if (user != null) {
        setState(() {
          _userNickname = user.nickname;
        });
      }

      // 포인트는 별도 API로 가져오기
      try {
        final dio = DioService.instance;
        final response = await dio.get('/members/me/point');

        if (response.data['success']) {
          setState(() {
              _point = (response.data['data']['point'] as num?)?.toInt() ?? 0;
          });
        }
      } catch (e) {
        print('Error fetching point: $e');
        setState(() {
          _point = 0;
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        _userNickname = '닉네임을 불러올 수 없음';
        _point = 0;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 사용자 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '닉네임',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _userNickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.go('/$currentLocale/cash-history'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('포인트 내역'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          '보유 포인트',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_point 포인트',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 메뉴 카드
            Card(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    title: '내정보수정',
                    onTap: () => context.go('/$currentLocale/profile-edit'),
                  ),
                  _buildMenuItem(
                    icon: Icons.article,
                    title: '공지사항',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: '제휴광고',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: '로그아웃',
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
