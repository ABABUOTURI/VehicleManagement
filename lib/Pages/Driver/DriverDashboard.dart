import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:vehicle/Pages/Driver/DriverCheckOutIn.dart';
import 'package:vehicle/Pages/Driver/ParkingSlot.dart';
import 'package:vehicle/Pages/Driver/Payment.dart';
import 'package:vehicle/Pages/Driver/PrintRecipt.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/vehicle.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  late Box<ParkingSlot> parkingSlotBox;
  late Box<Vehicle> vehicleBox;
  List<ParkingSlot> parkingSlots = [];
  List<Vehicle> vehicleHistory = [];
  Vehicle? currentReservation;
  List<String> notifications = [];
  int newParkingSlotsCount = 0; // Count for new parking slots

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    vehicleBox = await Hive.openBox<Vehicle>('vehicles');

    setState(() {
      parkingSlots = parkingSlotBox.values.toList();
      vehicleHistory = vehicleBox.values.toList();

      // Find the current active reservation safely
      currentReservation = vehicleHistory.firstWhere(
        (vehicle) => parkingSlotBox.get(vehicle.slotId)?.isOccupied ?? false,
         orElse: () => Vehicle(
    driverName: '',
    vehicleType: '',
    licensePlate: '',
    vehicleColor: '',
    slotId: -1,
    timestamp: DateTime.now(),
    phone: '', ticketId: '', email: '',
  ),
      );

      // Count the number of new parking slots added (example condition: slots added within the last day)
      newParkingSlotsCount = parkingSlots.where((slot) {
        return slot.addedTime != null && slot.addedTime!.isAfter(DateTime.now().subtract(Duration(days: 1)));
      }).length;

      // Populate notifications
      _updateNotifications();
    });
  }

  void _updateNotifications() {
    notifications.clear();
    if (currentReservation != null) {
      notifications.add(
          'Slot ${currentReservation!.slotId} is currently occupied. Check-in at ${DateFormat('yyyy-MM-dd – kk:mm').format(currentReservation!.timestamp)}');
    } else {
      notifications.add('No current reservations.');
    }

    // Notification for new parking slots added
    if (newParkingSlotsCount > 0) {
      notifications.add('New parking slots added: $newParkingSlotsCount');
    }

    notifications.add('Reminder: Ensure your payments are up to date.');
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 32; // Adjust to keep padding consistent

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: const Color(0xFF63D1F6),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to account settings
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // Drawer for additional navigation options
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Parking Summary
            _buildSectionHeader('Parking Summary'),
            SizedBox(width: cardWidth, child: _buildParkingSummaryCard()),

            const SizedBox(height: 16),
            // Section 2: Billing Information
            _buildSectionHeader('Billing Information'),
            SizedBox(width: cardWidth, child: _buildBillingInfoCard()),

            const SizedBox(height: 16),
            // Section 3: Notifications
            _buildSectionHeader('Notifications'),
            SizedBox(width: cardWidth, child: _buildNotificationsCard()),

            const SizedBox(height: 16),
            // Section 4: Parking History
            _buildSectionHeader('Parking History'),
            SizedBox(width: cardWidth, child: _buildParkingHistoryCard()),
          ],
        ),
      ),
    );
  }

  // Build drawer for account settings and additional navigation options
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF63D1F6),
            ),
            child: Text(
              'Driver Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Check-In Check-Out'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckInCheckOutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_parking),
            title: const Text('Parking Slot'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParkingSlotsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Payment()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt'),
            onTap: () {
              if (currentReservation != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrintReceiptPage(
                      slotId: currentReservation!.slotId,
                      checkInTime: currentReservation!.timestamp,
                      checkOutTime: DateTime.now(), // Replace with actual data if available
                      totalCost: 100.0, // Replace with calculated data
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Section Header
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

  // Parking Summary Card
  Widget _buildParkingSummaryCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentReservation != null
            ? Text(
                'Current Reservation: Slot ${currentReservation!.slotId}, check-in at ${DateFormat('yyyy-MM-dd – kk:mm').format(currentReservation!.timestamp)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text('No current reservations.'),
      ),
    );
  }

  // Billing Information Card
  Widget _buildBillingInfoCard() {
    if (vehicleHistory.isEmpty) {
      return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No billing information available.'),
        ),
      );
    }

    double pendingPayments = vehicleHistory.length * 100.0; // Example calculation
    double lastPayment = 100.0; // Replace with actual last payment from history

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Payments: Ksh${pendingPayments.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Last Payment: Ksh${lastPayment.toStringAsFixed(2)} on 10/21/2024'),
          ],
        ),
      ),
    );
  }

  // Notifications Card
  Widget _buildNotificationsCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.isNotEmpty
              ? notifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(notification),
                  );
                }).toList()
              : const [Text('No notifications available.')],
        ),
      ),
    );
  }

  // Parking History Card
  Widget _buildParkingHistoryCard() {
    if (vehicleHistory.isEmpty) {
      return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No parking history available.'),
        ),
      );
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: vehicleHistory.map((vehicle) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slot ${vehicle.slotId}: ${DateFormat('yyyy-MM-dd – kk:mm').format(vehicle.timestamp)}, ${vehicle.timestamp.difference(vehicle.timestamp).inHours} hours',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
