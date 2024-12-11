import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import 'package:intl/intl.dart';

class CashHistory {
  final int id;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;
  final double balance;

  CashHistory({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.balance,
  });

  factory CashHistory.fromJson(Map<String, dynamic> json) {
    return CashHistory(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      balance: json['balance'].toDouble(),
    );
  }
}

class CashHistoryScreen extends StatefulWidget {
  const CashHistoryScreen({super.key});

  @override
  State<CashHistoryScreen> createState() => _CashHistoryScreenState();
}

class _CashHistoryScreenState extends State<CashHistoryScreen> {
  List<CashHistory> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCashHistory();
  }

  Future<void> _fetchCashHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioService.instance;
      final response = await dio.get('/members/me/cash-history');

      if (response.data['success']) {
        final List<dynamic> historyData = response.data['data'];
        setState(() {
          _histories = historyData.map((data) => CashHistory.fromJson(data)).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cash history: $e');
      }
      // TODO: Show error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('캐시 내역'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          final history = _histories[index];
          return ListTile(
            leading: Icon(
              history.type == 'EARN' ? Icons.add_circle : Icons.remove_circle,
              color: history.type == 'EARN' ? Colors.green : Colors.red,
            ),
            title: Text(history.description),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(history.createdAt)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${history.type == 'EARN' ? '+' : '-'}${history.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: history.type == 'EARN' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '잔액: ${history.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
