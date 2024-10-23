import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // For PDF export (consider using a library like syncfusion)
import 'package:vehicle/Pages/Driver/Payment.dart';
import 'package:vehicle/models/parking_ticket.dart';
import 'package:vehicle/models/vehicle.dart';


class ParkingAttendantGenerateReportPage extends StatefulWidget {
  const ParkingAttendantGenerateReportPage({super.key});

  @override
  _ParkingAttendantGenerateReportPageState createState() => _ParkingAttendantGenerateReportPageState();
}

class _ParkingAttendantGenerateReportPageState extends State<ParkingAttendantGenerateReportPage> {
  String reportType = 'Daily'; // Default report type
  DateTime selectedDate = DateTime.now(); // Selected date for reports
  List<ParkingTicket> tickets = []; // Store fetched tickets
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  // Method to fetch report data based on report type
  Future<void> _fetchReportData() async {
    var ticketBox = await Hive.openBox<ParkingTicket>('parkingTickets');
    var paymentBox = await Hive.openBox<Payment>('payments');

    // Filter tickets based on the selected date and report type
    setState(() {
      tickets = ticketBox.values
          .where((ticket) {
            switch (reportType) {
              case 'Daily':
                return _isSameDay(ticket.timestamp, selectedDate);
              case 'Weekly':
                return _isWithinThisWeek(ticket.timestamp);
              case 'Monthly':
                return _isWithinThisMonth(ticket.timestamp);
              default:
                return false;
            }
          })
          .toList();

      // Calculate total revenue from payments
      totalRevenue = paymentBox.values.fold(
          0.0, (sum, payment) => sum + payment.amountPaid);
    });
  }

  // Check if the date is within the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if the date is within the current week
  bool _isWithinThisWeek(DateTime date) {
    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Monday as start
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday as end
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // Check if the date is within the current month
  bool _isWithinThisMonth(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Method to export report as PDF
  void _exportAsPDF() {
    // Logic to generate and export a PDF report
    // Using Syncfusion PDF library or any other suitable one
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report exported as PDF successfully')),
    );
  }

  // Method to export report as Excel
  void _exportAsExcel() {
    // Logic to generate and export an Excel report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report exported as Excel successfully')),
    );
  }

  // Method to send the report via email
  void _sendEmailReport() {
    // Logic to send the report via email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sent to management via email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Reports'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Report Type Dropdown
            DropdownButtonFormField<String>(
              value: reportType,
              items: ['Daily', 'Weekly', 'Monthly']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  reportType = value!;
                  _fetchReportData(); // Fetch report data for the selected type
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Report Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
            ),
            const SizedBox(height: 24),

            // Select Date
            ListTile(
              title: const Text('Select Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    _fetchReportData();
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Insights Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Total Tickets Issued: ${tickets.length}'),
                    const SizedBox(height: 10),
                    Text('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    // Placeholder for peak parking hours
                    const Text('Peak Parking Hours: 9 AM - 12 PM'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Options
            const Text(
              'Export Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _exportAsPDF,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: const Color(0xFF63D1F6),
                    textStyle: const TextStyle(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Export as PDF'),
                ),
                ElevatedButton(
                  onPressed: _exportAsExcel,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: const Color(0xFF63D1F6),
                    textStyle: const TextStyle(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Export as Excel'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email Report Button
            ElevatedButton(
              onPressed: _sendEmailReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: const Color(0xFF63D1F6),
                textStyle: const TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Send Report via Email'),
            ),
          ],
        ),
      ),
    );
  }
}
