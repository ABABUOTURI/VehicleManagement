import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintReceiptPage extends StatefulWidget {
  final int slotId; // Slot ID to show the booked slot number
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final double hourlyRate; // Hourly rate for calculating total cost

  const PrintReceiptPage({
    super.key,
    required this.slotId,
    required this.checkInTime,
    required this.checkOutTime,
    this.hourlyRate = 100.0, required double totalCost, // Default rate set to 100 Ksh per hour
  });

  @override
  _PrintReceiptPageState createState() => _PrintReceiptPageState();
}

class _PrintReceiptPageState extends State<PrintReceiptPage> {
  // Method to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  // Method to calculate total time parked
  String _calculateTimeParked() {
    Duration timeSpent = widget.checkOutTime.difference(widget.checkInTime);
    return "${timeSpent.inHours} hours, ${timeSpent.inMinutes % 60} minutes";
  }

  // Method to calculate total cost based on time parked
  double _calculateTotalCost() {
    Duration timeSpent = widget.checkOutTime.difference(widget.checkInTime);
    double totalCost = (timeSpent.inMinutes / 60) * widget.hourlyRate;
    return totalCost;
  }

  // Method to handle digital receipt (email option)
  void _emailReceipt() {
    // Simulating sending the receipt via email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt sent to your email!')),
    );
  }

  // Method to handle physical receipt printing (dummy)
  void _printReceipt() {
    // Simulating printing the receipt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt printed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = _calculateTotalCost();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Receipt'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Details
            Card(
              color: const Color(0xFF63D1F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receipt Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Slot Booked: ${widget.slotId}'),
                    Text('Time In: ${_formatDateTime(widget.checkInTime)}'),
                    Text('Time Out: ${_formatDateTime(widget.checkOutTime)}'),
                    const SizedBox(height: 8),
                    Text('Total Time Parked: ${_calculateTimeParked()}'),
                    const SizedBox(height: 8),
                    Text('Total Cost: Ksh${totalCost.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons for Receipt Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Print Button
                ElevatedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),

                // Email Button
                ElevatedButton.icon(
                  onPressed: _emailReceipt,
                  icon: const Icon(Icons.email),
                  label: const Text('Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63D1F6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
