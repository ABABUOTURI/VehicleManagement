import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  String _selectedReportRange = 'Daily';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Sample data for insights
  int checkIns = 120;
  int checkOuts = 100;
  double revenue = 5000.0;
  int occupancyRate = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf), // PDF export icon
            onPressed: _exportToPDF, // Call export to PDF method
          ),
          IconButton(
            icon: const Icon(Icons.table_chart), // Excel export icon
            onPressed: _exportToExcel, // Call export to Excel method
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report range dropdown
            Row(
              children: [
                const Text(
                  'Select Report Range:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedReportRange,
                  items: ['Daily', 'Weekly', 'Monthly']
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReportRange = value!;
                      _updateDateRange(); // Update date range based on selection
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Range Display
            const Text(
              'Report Date Range:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Insights Section
            const Text(
              'Parking Lot Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Check-Ins'),
                subtitle: Text('Total Check-Ins: $checkIns'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Check-Outs'),
                subtitle: Text('Total Check-Outs: $checkOuts'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on),
                title: const Text('Parking Revenue'),
                subtitle: Text('Total Revenue: \$${revenue.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Occupancy Rate'),
                subtitle: Text('Occupancy: $occupancyRate%'),
              ),
            ),
            const SizedBox(height: 20),

            // Generate Report Button
            Center(
              child: ElevatedButton(
                onPressed: _generateReport,
                child: const Text('Generate Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update date range based on the selected report range (Daily, Weekly, Monthly)
  void _updateDateRange() {
    if (_selectedReportRange == 'Daily') {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    } else if (_selectedReportRange == 'Weekly') {
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
    } else if (_selectedReportRange == 'Monthly') {
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
    }
  }

  // Method to generate the report (dummy implementation)
  void _generateReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Generated'),
          content: Text(
              'The report for the period ${DateFormat.yMMMd().format(_startDate)} to ${DateFormat.yMMMd().format(_endDate)} has been generated.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to export report to PDF (dummy implementation)
  void _exportToPDF() {
    // Placeholder for actual PDF export functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export to PDF'),
          content: const Text('The report has been exported to PDF format.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to export report to Excel (dummy implementation)
  void _exportToExcel() {
    // Placeholder for actual Excel export functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export to Excel'),
          content: const Text('The report has been exported to Excel format.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
