import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _allNotifications = true;
  bool _academicNotif = true;
  bool _eventsNotif = true;
  bool _placementsNotif = true;
  bool _urgentNotif = true;
  bool _examsNotif = true;
  bool _resultsNotif = true;
  bool _holidaysNotif = true;
  bool _sportsNotif = true;
  bool _generalNotif = true;

  Future<void> _toggleNotification(String topic, bool enabled) async {
    if (enabled) {
      await _notificationService.subscribeToTopic(topic);
    } else {
      await _notificationService.unsubscribeFromTopic(topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Manage which notifications you receive',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('All Notifications'),
            subtitle: const Text('Receive all notice notifications'),
            value: _allNotifications,
            onChanged: (value) {
              setState(() => _allNotifications = value);
              if (value) {
                _notificationService.subscribeToAll();
              } else {
                _notificationService.unsubscribeFromTopic('all_notices');
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'BY CATEGORY',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            secondary: const Text('📚', style: TextStyle(fontSize: 24)),
            title: const Text('Academic'),
            subtitle: const Text('Exams, schedules, syllabus updates'),
            value: _academicNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _academicNotif = value);
                    _toggleNotification('cat_academic', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('📝', style: TextStyle(fontSize: 24)),
            title: const Text('Examinations'),
            subtitle: const Text('Exam schedules and updates'),
            value: _examsNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _examsNotif = value);
                    _toggleNotification('cat_exams', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('📊', style: TextStyle(fontSize: 24)),
            title: const Text('Results'),
            subtitle: const Text('Exam results and scores'),
            value: _resultsNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _resultsNotif = value);
                    _toggleNotification('cat_results', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('🎉', style: TextStyle(fontSize: 24)),
            title: const Text('Events'),
            subtitle: const Text('College events and activities'),
            value: _eventsNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _eventsNotif = value);
                    _toggleNotification('cat_events', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('💼', style: TextStyle(fontSize: 24)),
            title: const Text('Placements'),
            subtitle: const Text('Job opportunities and drives'),
            value: _placementsNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _placementsNotif = value);
                    _toggleNotification('cat_placements', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('🏖️', style: TextStyle(fontSize: 24)),
            title: const Text('Holidays'),
            subtitle: const Text('Holiday announcements'),
            value: _holidaysNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _holidaysNotif = value);
                    _toggleNotification('cat_holidays', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('⚽', style: TextStyle(fontSize: 24)),
            title: const Text('Sports'),
            subtitle: const Text('Sports events and achievements'),
            value: _sportsNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _sportsNotif = value);
                    _toggleNotification('cat_sports', value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Text('🚨', style: TextStyle(fontSize: 24)),
            title: const Text('Urgent'),
            subtitle: const Text('Important and urgent notices'),
            value: _urgentNotif,
            onChanged: _allNotifications
                ? (value) {
                    setState(() => _urgentNotif = value);
                    _toggleNotification('cat_urgent', value);
                  }
                : null,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'How it works',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You will receive push notifications based on your preferences. '
                      'Notifications are also sent based on your department and year if specified in your profile.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
