import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';

class Mission {
  final int id;
  final String title;
  final String description;
  final int rewardPoint;
  final String missionUrl;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoint,
    required this.missionUrl,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoint: json['rewardPoint'] as int,
      missionUrl: json['missionUrl'] as String,
    );
  }
}

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  List<Mission> missions = [];
  int? hoveredMissionId;
  bool isLoading = false;
  String errorMessage = '';
  int currentPage = 0;
  int totalElements = 0;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMissions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && !isLastPage) {
        _fetchMissions(page: currentPage + 1);
      }
    }
  }

  Future<void> _fetchMissions({int page = 0}) async {
    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final dio = DioService.instance;
      final response = await dio.get('/active-missions', queryParameters: {
        'page': page,
        'size': 20,
      });

      if (response.data != null && response.data['data'] != null) {
        final pageData = response.data['data'];
        final List<dynamic> missionList = pageData['content'];
        final newMissions = missionList.map((json) => Mission.fromJson(json)).toList();
        
        setState(() {
          if (page == 0) {
            missions = newMissions;
          } else {
            missions.addAll(newMissions);
          }
          currentPage = page;
          totalElements = pageData['totalElements'];
          isLastPage = pageData['last'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '미션 목록을 불러올 수 없습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching missions: $e');
      setState(() {
        errorMessage = '미션 목록을 불러오는 중 오류가 발생했습니다.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('미션 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final locale = Localizations.localeOf(context).languageCode;
            context.go('/$locale/home');
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchMissions(page: 0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: missions.length + (isLoading && !isLastPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == missions.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final mission = missions[index];
                    return MouseRegion(
                      onEnter: (_) => setState(() => hoveredMissionId = mission.id),
                      onExit: (_) => setState(() => hoveredMissionId = null),
                      child: _buildMissionCard(mission, currentLocale),
                    );
                  },
                ),
              ),
            ),
            if (isLoading && missions.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _fetchMissions(page: 0),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, String locale) {
    final isHovered = hoveredMissionId == mission.id;
    return Card(
      elevation: isHovered ? 8 : 2,
      child: InkWell(
        onTap: () {
          final locale = Localizations.localeOf(context).languageCode;
          context.go('/$locale/mission/${mission.id}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  mission.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${mission.rewardPoint}P',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
