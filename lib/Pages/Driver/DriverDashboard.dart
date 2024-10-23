 import 'package:flutter/material.dart';
import 'package:vehicle/Pages/Driver/DRiverVehicleRegistration.dart';
import 'package:vehicle/Pages/Driver/DriverCheckOutIn.dart';
import 'package:vehicle/Pages/Driver/ParkingSlot.dart';
import 'package:vehicle/Pages/Driver/Payment.dart';
import 'package:vehicle/Pages/Driver/PrintRecipt.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  Widget build(BuildContext context) {
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
            _buildParkingSummary(),

            const SizedBox(height: 16),
            // Section 2: Billing Information
            _buildSectionHeader('Billing Information'),
            _buildBillingInfo(),

            const SizedBox(height: 16),
            // Section 3: Notifications
            _buildSectionHeader('Notifications'),
            _buildNotifications(),

            const SizedBox(height: 16),
            // Section 4: Parking History
            _buildSectionHeader('Parking History'),
            _buildParkingHistory(),
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
                    MaterialPageRoute(
                        builder: (context) => CheckInCheckOutPage()),
                  );
                },
          ),
           ListTile(
            leading: const Icon(Icons.local_parking),
            title: const Text('Parking Slot'),
            onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingSlotsPage ()),
                  );
                },
          ),
           ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment'),
             onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Payment()),
                  );
                },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt'),
             onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrintReceiptPage(checkInTime: null!, checkOutTime: null!, totalCost: null!,)),
                  );
                },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Payment Methods'),
             onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckInCheckOutPage()),
                  );
                },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Vehicle Registration'),
             onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DRVehicleRegistrationPage()),
                  );
                },
          ),
          ListTile(
            leading: const Icon(Icons.insights),
            title: const Text('Parking Insights'),
             onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckInCheckOutPage()),
                  );
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

  // Parking Summary
  Widget _buildParkingSummary() {
    return Card(
      color: const Color(0xFFDEAF4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Reservation: Slot B3 on 1st Floor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Current Reservation: Slot B10, ends in 2 hours'),
            SizedBox(height: 8),
            Text('Past Reservations: B5, B8, B2'),
          ],
        ),
      ),
    );
  }

  // Billing Information
  Widget _buildBillingInfo() {
    return Card(
      color: const Color(0xFF63D1F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Payments: \$50.00',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last Payment: \$20.00 on 10/21/2024'),
            SizedBox(height: 8),
            Text('Receipts Available: View Past Payments'),
          ],
        ),
      ),
    );
  }

  // Notifications
  Widget _buildNotifications() {
    return Card(
      color: const Color(0xFFE8EAF6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New parking spot available at B4 on 2nd floor.'),
            SizedBox(height: 8),
            Text('Reminder: Payment for Slot B5 is overdue by 2 days.'),
          ],
        ),
      ),
    );
  }

  // Parking History
  Widget _buildParkingHistory() {
    return Card(
      color: const Color(0xFF63D1F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'B5: 10/10/2024, 2 hours',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('B8: 10/15/2024, 3 hours'),
            SizedBox(height: 8),
            Text('B2: 10/20/2024, 4 hours'),
          ],
        ),
      ),
    );
  }
}
