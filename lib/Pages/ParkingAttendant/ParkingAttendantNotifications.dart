import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ParkingAttendantNotificationsPage extends StatefulWidget {
  const ParkingAttendantNotificationsPage({super.key});

  @override
  _ParkingAttendantNotificationsPageState createState() =>
      _ParkingAttendantNotificationsPageState();
}

class _ParkingAttendantNotificationsPageState
    extends State<ParkingAttendantNotificationsPage> {
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
   
  }

  // Method to fetch notifications from the Hive database
 

  // Helper function to get notification icon based on type
  IconData _getIcon(String type) {
    switch (type) {
      case 'Alert':
        return Icons.warning_amber_rounded;
      case 'Ticket':
        return Icons.money_off;
      case 'Warning':
        return Icons.timer_off_rounded;
      case 'Reservation':
        return Icons.event_seat;
      default:
        return Icons.notification_important;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  'No notifications available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notification = notifications[index];
                  return Card(
                    color: Colors.white, // White background for floating card
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIcon(notification['type']!),
                        color: Colors.blueGrey,
                        size: 40,
                      ),
                      title: Text(
                        notification['title']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        notification['description']!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onTap: () {
                        _showNotificationDetails(notification);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Dialog to show detailed notification content
  void _showNotificationDetails(Map<String, String> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']!),
        content: Text(notification['description']!),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
