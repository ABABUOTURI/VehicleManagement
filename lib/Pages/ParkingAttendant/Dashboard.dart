import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/Pages/ParkingAttendant/CheckParkingTicket.dart';
import 'package:vehicle/Pages/ParkingAttendant/ManageParking.dart';
import 'package:vehicle/Pages/ParkingAttendant/ParkingAttendantNotifications.dart';
import 'package:vehicle/Pages/ParkingAttendant/ParkingAttendantReport.dart';
import 'package:vehicle/Pages/ParkingAttendant/vehicleRegistration.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class ParkingAttendantDashboard extends StatefulWidget {
  final String email;

  const ParkingAttendantDashboard({super.key, required this.email});

  @override
  _ParkingAttendantDashboardState createState() =>
      _ParkingAttendantDashboardState();
}

class _ParkingAttendantDashboardState extends State<ParkingAttendantDashboard> {
  String userName = ''; // Store the attendant's name
  int totalVehicles = 0;
  int totalTicketsIssued = 0;
  int occupiedSlots = 0;
  int totalSlots = 0;
  int unpaidTickets = 0;
  int overdueReports = 0;

  @override
  void initState() {
    super.initState();
    _fetchAttendantName();
    _fetchVehicleData();
    _fetchParkingSlotData();
    _fetchTicketsData();
  }

  // Method to fetch the attendant's name
  Future<void> _fetchAttendantName() async {
    var userBox = await Hive.openBox('users');
    var user = userBox.get(widget.email);
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  // Method to fetch vehicle data
  Future<void> _fetchVehicleData() async {
    var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
    setState(() {
      totalVehicles = vehicleBox.length;
    });
  }

  // Method to fetch parking slot data
  Future<void> _fetchParkingSlotData() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    setState(() {
      totalSlots = parkingSlotBox.length;
      occupiedSlots = parkingSlotBox.values
          .where((slot) => slot.isOccupied == true)
          .length;
    });
  }

  // Method to fetch ticket data (for unpaid and overdue tickets)
  Future<void> _fetchTicketsData() async {
    setState(() {
      unpaidTickets = 5; // Placeholder for unpaid tickets count
      overdueReports = 3; // Placeholder for overdue reports
      totalTicketsIssued = 100; // Placeholder for total tickets issued
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFCF6F5),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF63D1F6),
                ),
                child: Text(
                  'Parking Attendant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Register Vehicle'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingVehicleRegistrationPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text('Check Parking Tickets'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckParkingTicketsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Generate Report'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingAttendantGenerateReportPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_parking),
                title: const Text('Manage Parking'),
               onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PAManageParkingPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification Settings'),
               onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingAttendantNotificationsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview section
              Card(
                color: const Color(0xFFDEAF4B), // Overview background
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585D61), // Text color
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Vehicles Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.directions_car,
                              color: Color(0xFF585D61)),
                          title: const Text('Currently Parked Vehicles',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Total Vehicles: $totalVehicles',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tickets Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.local_parking,
                              color: Color(0xFF585D61)),
                          title: const Text('Parking Tickets',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Total Tickets Issued: $totalTicketsIssued',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Parking Utilization Card
                      Card(
                        color: const Color(0xFF63D1F6),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.local_parking,
                              color: Color(0xFF585D61)),
                          title: const Text('Parking Utilization',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text(
                              'Occupied Slots: $occupiedSlots / $totalSlots',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Alerts section
              Card(
                color: const Color(0xFF63D1F6), // Alerts background color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF585D61),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Unpaid Tickets Card
                      Card(
                        color: const Color(0xFFDEAF4B),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading:
                              const Icon(Icons.warning, color: Color(0xFF585D61)),
                          title: const Text('Unpaid Parking Tickets',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Total Unpaid Tickets: $unpaidTickets',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Overdue Reports Card
                      Card(
                        color: const Color(0xFFDEAF4B),
                        elevation: 4,
                        shadowColor: Colors.grey[400],
                        child: ListTile(
                          leading: const Icon(Icons.report_problem,
                              color: Color(0xFF585D61)),
                          title: const Text('Overdue Reports',
                              style: TextStyle(color: Color(0xFF585D61))),
                          subtitle: Text('Total Overdue Reports: $overdueReports',
                              style: const TextStyle(color: Color(0xFF585D61))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
