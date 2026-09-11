import 'package:flutter/material.dart';

import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/services/activity_service.dart';
import '../../../dashboard/presentation/widgets/activity_feed.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final _activityService = ActivityService();

  List<ActivityModel>? _activities;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final data = await _activityService.getRecentActivities(limit: 50);

    if (!mounted) return;

    setState(() {
      _activities = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua Aktivitas')),
      body: _activities == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActivities,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ActivityFeed(activities: _activities!),
                ],
              ),
            ),
    );
  }
}