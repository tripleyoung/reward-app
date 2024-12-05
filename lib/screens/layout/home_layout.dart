import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/responsive.dart';

class HomeLayout extends StatelessWidget {
  final Widget child;

  const HomeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final isDesktop = !isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // 데스크탑용 사이드바
              if (isDesktop)
                SizedBox(
                  width: isTablet(context) ? 200 : 240,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'REWARD',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildMenuItem(
                                context: context,
                                icon: Icons.home,
                                label: '홈',
                                onTap: () => context.go('/$currentLocale/home'),
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.account_balance_wallet,
                                label: '적립',
                                onTap: () => context.go('/$currentLocale/withdrawal-request'),
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.description,
                                label: '포인트 내역',
                                onTap: () => context.go('/$currentLocale/cash-history'),
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.person,
                                label: '마이페이지',
                                onTap: () => context.go('/$currentLocale/mypage'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 메인 콘텐츠
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: child,
                ),
              ),

              // 광고 영역
              if (isDesktop)
                SizedBox(
                  width: isTablet(context) ? 200 : 240,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '광고',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAdBanner('광고 배너 1'),
                        const SizedBox(height: 16),
                        _buildAdBanner('광고 배너 2'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      
      // 모바일용 하단 네비게이션 바
      bottomNavigationBar: isMobile(context)
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(
                        context: context,
                        icon: Icons.home,
                        label: '홈',
                        onTap: () => context.go('/$currentLocale/home'),
                      ),
                      _buildBottomNavItem(
                        context: context,
                        icon: Icons.account_balance_wallet,
                        label: '립',
                        onTap: () => context.go('/$currentLocale/withdrawal-request'),
                      ),
                      _buildBottomNavItem(
                        context: context,
                        icon: Icons.description,
                        label: '포인트 내역',
                        onTap: () => context.go('/$currentLocale/cash-history'),
                      ),
                      _buildBottomNavItem(
                        context: context,
                        icon: Icons.person,
                        label: '마이페이지',
                        onTap: () => context.go('/$currentLocale/mypage'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner(String label) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }
} 