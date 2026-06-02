import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notifsJson = prefs.getStringList('notifications') ?? [];

    setState(() {
      _notifications = notifsJson
          .map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList(); // Newest first
      _isLoading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedList = _notifications.map((n) {
      n['is_read'] = true;
      return jsonEncode(n);
    }).toList();

    await prefs.setStringList('notifications', updatedList.reversed.toList());

    setState(() {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All marked as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.primary),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 60, color: Colors.white38),
                      SizedBox(height: 16),
                      Text('No new notifications',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['is_read'] == true;

                    return ListTile(
                      tileColor: isRead
                          ? Colors.transparent
                          : AppColors.surface.withOpacity(0.5),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.notifications,
                            color: AppColors.primary),
                      ),
                      title: Text(
                        notif['title'] ?? 'Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notif['body'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
    );
  }
}
