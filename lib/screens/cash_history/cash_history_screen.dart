import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';

class Transaction {
  final String title;
  final String date;
  final int amount;

  Transaction({
    required this.title,
    required this.date,
    required this.amount,
  });
}

class CashHistoryScreen extends StatefulWidget {
  const CashHistoryScreen({super.key});

  @override
  State<CashHistoryScreen> createState() => _CashHistoryScreenState();
}

class _CashHistoryScreenState extends State<CashHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Transaction>> transactions = {
    '출금내역': [],
    '적립내역': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPointDetail();
  }

  Future<void> _fetchPointDetail() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.userId;
      
      if (userId != null) {
        final dio = DioService.getInstance(context);
        final response = await dio.post('/my/point/detail', data: {'userId': userId});

        if (response.data != null) {
          final fetchedTransactions = (response.data as List).map((transaction) {
            final date = DateTime.parse(transaction['pointDate']);
            final formattedDate = date.toLocal().toString()
                .replaceAll('.', '-')
                .substring(0, 19); // YYYY-MM-DD HH:mm:ss 형식

            return Transaction(
              title: transaction['pointAction'] == 'POINT_WITHDRAW' ? '출금' : '적립',
              date: formattedDate,
              amount: transaction['pointDelta'],
            );
          }).toList();

          setState(() {
            transactions = {
              '출금내역': fetchedTransactions.where((t) => t.title == '출금').toList(),
              '적립내역': fetchedTransactions.where((t) => t.title == '적립').toList(),
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching point detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 내��'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '출금내역'),
            Tab(text: '적립내역'),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(transactions['출금내역'] ?? []),
          _buildTransactionList(transactions['적립내역'] ?? []),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => context.go('/$currentLocale/withdrawal-request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('출금 신청하기'),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final transaction = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${transaction.amount > 0 ? '+' : ''}${transaction.amount} 포인트',
                  style: TextStyle(
                    color: transaction.amount > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 