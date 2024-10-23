import 'package:flutter/material.dart';

class ParkingAttendantNotificationsPage extends StatefulWidget {
  const ParkingAttendantNotificationsPage({super.key});

  @override
  _ParkingAttendantNotificationsPageState createState() =>
      _ParkingAttendantNotificationsPageState();
}

class _ParkingAttendantNotificationsPageState
    extends State<ParkingAttendantNotificationsPage> {
  // Example notifications data
  List<Map<String, String>> notifications = [
    {
      'title': 'Parking Lot Full',
      'description': 'The parking lot is at full capacity.',
      'type': 'Alert'
    },
    {
      'title': 'Unpaid Ticket',
      'description': 'Vehicle ABC-123 has unpaid parking dues.',
      'type': 'Ticket'
    },
    {
      'title': 'Overdue Parking',
      'description': 'Vehicle XYZ-987 has overstayed the time limit.',
      'type': 'Warning'
    },
    {
      'title': 'Slot Reserved',
      'description': 'Slot 15 has been reserved for VIP parking.',
      'type': 'Reservation'
    },
  ];

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

  // Helper function to get color based on notification type
  Color _getColor(String type) {
    switch (type) {
      case 'Alert':
        return Colors.redAccent;
      case 'Ticket':
        return Colors.orange;
      case 'Warning':
        return Colors.amber;
      case 'Reservation':
        return Colors.blueAccent;
      default:
        return Colors.grey;
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
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            var notification = notifications[index];
            return Card(
              color: _getColor(notification['type']!), // Set color based on type
              elevation: 4,
              shadowColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  _getIcon(notification['type']!),
                  color: Colors.white,
                  size: 40,
                ),
                title: Text(
                  notification['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  notification['description']!,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 20,
                ),
                onTap: () {
                  // Action to view more details about the notification
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
