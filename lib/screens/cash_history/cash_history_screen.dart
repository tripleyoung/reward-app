import 'package:flutter/foundation.dart';
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
    debugPrint('Parsing JSON: $json');
    
    return CashHistory(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? 
        DateTime.parse(json['createdAt']) : 
        DateTime.now(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

class CashHistoryScreen extends StatefulWidget {
  const CashHistoryScreen({super.key});

  @override
  State<CashHistoryScreen> createState() => _CashHistoryScreenState();
}

class _CashHistoryScreenState extends State<CashHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<CashHistory> _histories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _currentType = 'ALL';
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
    
    Future.microtask(() {
      if (mounted) {
        _fetchCashHistory(refresh: true);
      }
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    setState(() {
      _setTypeFromTabIndex(_tabController.index);
      _histories = [];
      _currentPage = 0;
      _hasMore = true;
      _isLoading = false;
    });
    
    _fetchCashHistory(refresh: true);
  }

  void _setTypeFromTabIndex(int index) {
    switch (index) {
      case 0:
        _currentType = 'ALL';
        break;
      case 1:
        _currentType = 'WITHDRAWAL';
        break;
      case 2:
        _currentType = 'EARN';
        break;
      default:
        _currentType = 'ALL';
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _fetchCashHistory(refresh: false);
      }
    }
  }

  Future<void> _fetchCashHistory({required bool refresh}) async {
    if (_isLoading) return;

    debugPrint('Fetching cash history: type=$_currentType, page=${refresh ? 0 : _currentPage}');

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioService.instance;
      final response = await dio.get(
        '/members/me/cash-history',
        queryParameters: {
          'type': _currentType,
          'page': refresh ? 0 : _currentPage,
          'size': _pageSize,
          'sort': 'transactionDate,desc',
        },
      );

      debugPrint('Response received: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('No data received from server');
        }

        final content = data['content'] as List;
        final totalPages = data['totalPages'] as int;
        
        if (mounted) {
          setState(() {
            if (refresh) {
              _histories = content.map((data) => CashHistory.fromJson(data)).toList();
              _currentPage = 1;
            } else {
              _histories.addAll(content.map((data) => CashHistory.fromJson(data)).toList());
              _currentPage++;
            }
            _hasMore = _currentPage < totalPages;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(response.data['message'] ?? '거래 내역을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      debugPrint('Error fetching cash history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 내역'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '출금/충전'),
            Tab(text: '적립내역'),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchCashHistory(refresh: true),
        child: _isLoading && _histories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
          ? const Center(child: Text('거래 내역이 없습니다.'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _histories.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _histories.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final history = _histories[index];
                final isPositive = history.amount > 0;  // 금액의 부호로 판단
                
                return ListTile(
                  leading: Icon(
                    isPositive ? Icons.add_circle : Icons.remove_circle,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  title: Text(history.description),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(history.createdAt)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('+#,###;-#,###').format(history.amount),
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '잔액: ${NumberFormat('#,###').format(history.balance)}',
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
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
