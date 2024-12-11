import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Mission {
  final int id;
  final String title;
  final String description;
  final int rewardPoint;
  final String status;
  final String missionUrl;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoint,
    required this.status,
    required this.missionUrl,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoint: json['rewardPoint'] as int,
      status: json['status'] as String,
      missionUrl: json['missionUrl'] as String,
    );
  }
}

class MissionDetailScreen extends StatefulWidget {
  final String missionId;

  const MissionDetailScreen({
    super.key, 
    required this.missionId,
  });

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
      final dio = DioService.instance;
      final missionId = int.parse(widget.missionId);  
      final response = await dio.get('/active-missions/$missionId');

      if (response.data != null && response.data['data'] != null) {  
        setState(() {
          mission = Mission.fromJson(response.data['data']);  
        });
      } else {
        setState(() {
          _message = '미션 정보가 없습니다.';
        });
      }
    } catch (e) {
      debugPrint('Error fetching mission: $e');
      setState(() {
        _message = '미션을 불러오는데 실패했습니다.';
      });
    }
  }

  Future<void> _handleMissionAnswer() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = await authProvider.user;
      final userId = user?.userId;

      if (userId != null) {
        final dio = DioService.instance;
        await dio.post('/store-missions/${widget.missionId}/complete', data: {
          'userId': userId,
          'missionAnswer': _answerController.text,
        });

        setState(() => _message = '미션 완료했습니다!');
      }
    } catch (e) {
      setState(() => _message = '미션 실패!');
    }
  }

  Future<void> _copyKeyword() async {
    if (mission?.description != null) {
      await Clipboard.setData(ClipboardData(text: mission!.description));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('키워드가 클립보드에 복사되었습니다!')),
        );
      }
    }
  }

  Future<void> _launchURL() async {
    if (mission == null) return;
    
    try {
      final uri = Uri.parse(mission!.missionUrl);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        if (mounted) {
          setState(() => _message = 'URL을 열 수 없습니다. (${mission!.missionUrl})');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _message = '잘못된 URL 형식입니다: ${e.toString()}');
      }
    }
  }

  Future<void> _startMission() async {
    try {
      // 네트워크 연결 상태 확인
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // 연결 상태에 따른 처리
      if (connectivityResult == ConnectivityResult.none) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인터넷 연결이 필요합니다.')),
        );
        return;
      }

      // 와이파이 연결 시 미션 시작 불가
      if (connectivityResult == ConnectivityResult.wifi) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모바일 데이터로 연결 시에만 미션을 시작할 수 있습니다.')),
        );
        return;
      }

      // URL 실행
      if (mission?.missionUrl != null) {
        final url = Uri.parse(mission!.missionUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL을 실행할 수 있는 앱을 찾을 수 없습니다.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL 실행 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미션하기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final locale = Localizations.localeOf(context).languageCode;
            context.go('/$locale/missions');
          },
        ),
      ),
      body: mission == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '진행 설명',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      const TextSpan(text: '미션 '),
                                      TextSpan(
                                        text: '+${mission!.rewardPoint}P',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _copyKeyword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('키워드 복사하기'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStep('키워드 복사 붙여넣기'),
                                _buildStep('미션 시작'),
                                _buildStep('검색 결과에서 상품 찾기'),
                                _buildStep('상품 상세 페이지로 이동'),
                                _buildStep('상품번호 찾아서 복사'),
                                _buildStep('아래 정답란에 붙여넣기'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '진행팁',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '와이파이를 해제 후 모바일 데이터를 켠 상태에서, 복사한 키워드를 네이버 쇼핑 검색창에 붙여넣기 하여 검색해주세요.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        labelText: '상품번호 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleMissionAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('정답제출'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _startMission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('미션시작'),
                          ),
                        ),
                      ],
                    ),
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message,
                        style: TextStyle(
                          color: _message.contains('성공') ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
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
