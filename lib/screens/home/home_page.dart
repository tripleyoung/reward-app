   import 'package:flutter/foundation.dart';
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
      // 유저 정보는 AuthProvider에서 가져오기
      final authProvider = context.read<AuthProvider>();
      final user = await authProvider.user;
      
      if (user != null) {
        if (kDebugMode) {
          print('User info: ${user.toJson()}');
        }
        setState(() {
          _userNickname = user.nickname;
        });
      }

      // 포인트는 별도 API로 가져오기
      try {
        final dio = DioService.instance;
        final response = await dio.get('/members/me/point');

        if (kDebugMode) {
          print('Point response: ${response.data}');
        }

        if (response.data['success']) {
          setState(() {
            _point = (response.data['data']['point'] as num?)?.toInt() ?? 0;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching points: $e');
        }
        setState(() {
          _point = 0;
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching user info: $e');
        print('Stack trace: $stackTrace');
      }
      setState(() {
        _userNickname = '사용자';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = widget.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserInfo,
        child: SingleChildScrollView(
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
                        onPressed: () => context.go('/$currentLocale/cash-history'),
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
                    onTap: () => context.go('/$currentLocale/mission-list'),
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
