import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';

class Mission {
  final int rewardNo;
  final int rewardPoint;

  Mission({
    required this.rewardNo,
    required this.rewardPoint,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      rewardNo: json['rewardNo'] as int,
      rewardPoint: json['rewardPoint'] as int,
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

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/reward/mission/list');

      if (response.data != null) {
        final List<dynamic> missionsData = response.data;
        setState(() {
          missions =
              missionsData.map((data) => Mission.fromJson(data)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('미션하기'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.2,
          ),
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return MouseRegion(
              onEnter: (_) =>
                  setState(() => hoveredMissionId = mission.rewardNo),
              onExit: (_) => setState(() => hoveredMissionId = null),
              child: _buildMissionCard(mission, currentLocale),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, String currentLocale) {
    final isHovered = hoveredMissionId == mission.rewardNo;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.green],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.go('/$currentLocale/mission/${mission.rewardNo}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '미션 ${mission.rewardNo}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${mission.rewardPoint} 포인트',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isHovered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '시작하기',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
