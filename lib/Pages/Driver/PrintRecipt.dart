import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintReceiptPage extends StatefulWidget {
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final double totalCost;
  final double additionalCharges;

  const PrintReceiptPage({super.key, 
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalCost,
    this.additionalCharges = 0.0,
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
                    Text('Time In: ${_formatDateTime(widget.checkInTime)}'),
                    Text('Time Out: ${_formatDateTime(widget.checkOutTime)}'),
                    const SizedBox(height: 8),
                    Text('Total Time Parked: ${_calculateTimeParked()}'),
                    const SizedBox(height: 8),
                    Text('Total Cost: \$${widget.totalCost.toStringAsFixed(2)}'),
                    if (widget.additionalCharges > 0)
                      Text(
                        'Additional Charges: \$${widget.additionalCharges.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
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
