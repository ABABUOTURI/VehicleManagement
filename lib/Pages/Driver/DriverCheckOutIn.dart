import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class CheckInCheckOutPage extends StatefulWidget {
  const CheckInCheckOutPage({super.key});

  @override
  _CheckInCheckOutPageState createState() => _CheckInCheckOutPageState();
}

class _CheckInCheckOutPageState extends State<CheckInCheckOutPage> {
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckedIn = false;

  // Method to handle check-in
  void _handleCheckIn() {
    setState(() {
      checkInTime = DateTime.now();
      isCheckedIn = true;
    });
  }

  // Method to handle check-out and calculate time spent
  void _handleCheckOut() {
    setState(() {
      checkOutTime = DateTime.now();
      isCheckedIn = false;
    });
    _showCheckOutSummary();
  }

  // Show time summary after check-out
  void _showCheckOutSummary() {
    if (checkInTime != null && checkOutTime != null) {
      Duration timeSpent = checkOutTime!.difference(checkInTime!);
      String formattedTimeSpent =
          "${timeSpent.inHours} hours, ${timeSpent.inMinutes % 60} minutes";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Check-out Successful"),
          content: Text(
              "You have parked for $formattedTimeSpent.\nThe total charge will be calculated."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Format check-in/check-out times
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in / Check-out'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Parking Slot Status
            Card(
              color: const Color(0xFF63D1F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckedIn
                          ? 'Checked-in at: ${_formatDateTime(checkInTime)}'
                          : 'Not Checked-in',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (isCheckedIn)
                      ElevatedButton(
                        onPressed: _handleCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        child: Text('Check-out'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _handleCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        child: Text('Check-in'),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section: Time Tracking
            _buildSectionHeader('Time Tracking'),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF63D1F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in Time: ${_formatDateTime(checkInTime)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check-out Time: ${_formatDateTime(checkOutTime)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (checkInTime != null && checkOutTime != null)
                      Text(
                        'Time spent: ${checkOutTime!.difference(checkInTime!).inMinutes} minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF585D61),
      ),
    );
  }
}
