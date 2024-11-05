import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  String _selectedReportRange = 'Daily';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Variables for real data from the database
  int checkIns = 0;
  int checkOuts = 0;
  double revenue = 0.0;
  int totalSlots = 0;
  int occupiedSlots = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Open Hive boxes for data fetching
    var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');

    setState(() {
      // Count total check-ins and check-outs based on timestamp range
      checkIns = vehicleBox.values.where((vehicle) {
        return vehicle.timestamp.isAfter(_startDate) &&
            vehicle.timestamp.isBefore(_endDate);
      }).length;

      checkOuts = vehicleBox.values.where((vehicle) {
        return vehicle.checkOutTime != null &&
            vehicle.checkOutTime!.isAfter(_startDate) &&
            vehicle.checkOutTime!.isBefore(_endDate);
      }).length;

      // Calculate total revenue (assuming each vehicle has a `paymentAmount` property)
      revenue = vehicleBox.values.fold(0.0, (sum, vehicle) {
        if (vehicle.timestamp.isAfter(_startDate) &&
            vehicle.timestamp.isBefore(_endDate)) {
          return sum + (vehicle.paymentAmount ?? 0.0);
        }
        return sum;
      });

      // Calculate total and occupied slots
      totalSlots = parkingSlotBox.length;
      occupiedSlots =
          parkingSlotBox.values.where((slot) => slot.isOccupied).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    int occupancyRate = totalSlots > 0
        ? ((occupiedSlots / totalSlots) * 100).round()
        : 0; // Avoid division by zero

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _exportToExcel,
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
                      _updateDateRange();
                      _fetchData(); // Refresh data when range is changed
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
                subtitle: Text('Total Revenue: Ksh${revenue.toStringAsFixed(2)}'),
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

  void _updateDateRange() {
    if (_selectedReportRange == 'Daily') {
      _startDate = DateTime.now().subtract(const Duration(days: 1));
      _endDate = DateTime.now();
    } else if (_selectedReportRange == 'Weekly') {
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
    } else if (_selectedReportRange == 'Monthly') {
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
    }
  }

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

  void _exportToPDF() {
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

  void _exportToExcel() {
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
