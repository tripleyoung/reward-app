import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';

class HomePage extends StatefulWidget {
  final Locale locale;

  const HomePage({super.key, required this.locale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _point = 0;
  String _userNickname = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = await authProvider.user;
      final userId = user?.userId;

      if (userId != null) {
        final dio = DioService.instance;
        final response = await dio.post('/my/point', data: {'userId': userId});

        if (response.data['success']) {
          setState(() {
            _point = response.data['userPoint'] ?? 0;
            _userNickname = response.data['userNickname'] ?? '';
          });
        }
      }
    } catch (e) {
      setState(() {
        _point = 0;
        _userNickname = '닉네임을 불러올 수 없음';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('리워드'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 포인트 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userNickname,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${_point}p',
                            style: const TextStyle(
                              fontSize: 24,
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
                ),
              ),
              const SizedBox(height: 16),

              // 메뉴 그리드
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    icon: Icons.calendar_today,
                    label: '오늘의 미션',
                    onTap: () => context.go('/$currentLocale/today-mission'),
                  ),
                  _buildMenuCard(
                    icon: Icons.account_balance_wallet,
                    label: '적립',
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.description,
                    label: '포인트 내역',
                    onTap: () => context.go('/$currentLocale/cash-history'),
                  ),
                  _buildMenuCard(
                    icon: Icons.person,
                    label: '마이페이지',
                    onTap: () => context.go('/$currentLocale/mypage'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 미션하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/$currentLocale/missions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('미션하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
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
