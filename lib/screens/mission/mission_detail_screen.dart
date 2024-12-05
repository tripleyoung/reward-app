import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Mission {
  final int rewardPoint;
  final String keyword;
  final String advertiserChannel;
  final String productName;
  final String rewardProductPrice;
  final String priceComparison;

  Mission({
    required this.rewardPoint,
    required this.keyword,
    required this.advertiserChannel,
    required this.productName,
    required this.rewardProductPrice,
    required this.priceComparison,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      rewardPoint: json['rewardPoint'] as int,
      keyword: json['keyword'] as String,
      advertiserChannel: json['advertiserChannel'] as String,
      productName: json['productName'] as String,
      rewardProductPrice: json['rewardProductPrice'] as String,
      priceComparison: json['priceComparison'] as String,
    );
  }
}

class MissionDetailScreen extends StatefulWidget {
  final int rewardNo;

  const MissionDetailScreen({super.key, required this.rewardNo});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  Mission? mission;
  final _answerController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchMission();
  }

  Future<void> _fetchMission() async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get('/reward/mission/${widget.rewardNo}');
      
      if (response.data != null) {
        setState(() {
          mission = Mission.fromJson(response.data);
        });
      }
    } catch (e) {
      debugPrint('Error fetching mission: $e');
    }
  }

  Future<void> _handleMissionAnswer() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.userId;
      
      if (userId != null) {
        final dio = DioService.getInstance(context);
        await dio.post('/reward/mission/success/${widget.rewardNo}', data: {
          'userId': userId,
          'missionAnswer': _answerController.text,
        });
        
        setState(() => _message = '미션 성��했습니다!');
      }
    } catch (e) {
      setState(() => _message = '미션 실패!');
    }
  }

  Future<void> _copyKeyword() async {
    if (mission?.keyword != null) {
      await Clipboard.setData(ClipboardData(text: mission!.keyword));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('키워드가 클립보드에 복사되었습니다!')),
        );
      }
    }
  }

  Future<void> _launchMission() async {
    const url = 'https://shopping.naver.com/home';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('미션하기'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: mission == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMissionCard(),
                  const SizedBox(height: 16),
                  _buildTipCard(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildMissionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '미션 +${mission!.rewardPoint}p',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: _copyKeyword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('키워드 복사하기'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionList(),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: '상품번호 입력',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListItem('키워드 복사 붙여넣기'),
        _buildListItem('미션 시작'),
        _buildListItem('가격비교 여부: ${mission!.priceComparison}'),
        _buildListItem('상품명: ${mission!.productName}'),
        _buildListItem('판매처: ${mission!.advertiserChannel}'),
        _buildListItem('가격: ${mission!.rewardProductPrice}'),
        _buildListItem('아래로 스크롤 해서 구매추가정보를 눌러'),
        _buildListItem('상품번호를 복사후'),
        _buildListItem('정답란에 붙여넣기 확인 입력'),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '진행팁',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '와이파이를 해제 후 모바일 데이터를 켠 상태에서, 복사한 키워드를 네이버 쇼핑 검색창에 붙여넣기 하여 검색해주세요.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleMissionAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '정답제출',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _launchMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '미션시작',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
} 