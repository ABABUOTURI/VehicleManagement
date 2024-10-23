import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';

class SystemManagementPage extends StatefulWidget {
  const SystemManagementPage({super.key});

  @override
  _SystemManagementPageState createState() => _SystemManagementPageState();
}

class _SystemManagementPageState extends State<SystemManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showFloatingButton = false; // Variable to toggle the floating action button

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Add listener to detect when the tab changes
    _tabController.addListener(() {
      setState(() {
        // Show the floating button only on the "Parking Slots" tab
        showFloatingButton = _tabController.index == 2;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF63D1F6),
        title: const Text('System Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Vehicles'),
            Tab(text: 'Parking Slots'),
            Tab(text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: _backupData,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restoreData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserManagementTab(),
          _buildVehicleManagementTab(),
          _buildParkingSlotManagementTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              onPressed: _addParkingSlot,
              backgroundColor: const Color(0xFF63D1F6), // Add Parking Slot button
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  // Fetch and Display Users from Hive
  Widget _buildUserManagementTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<User>('users').listenable(),
      builder: (context, Box<User> userBox, _) {
        if (userBox.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userBox.length,
                itemBuilder: (context, index) {
                  User? user = userBox.getAt(index);
                  return Card(
                    color: const Color(0xFFDEAF4B),
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('User: ${user?.name ?? 'N/A'}'),
                      subtitle: Text('Role: ${user?.role ?? 'N/A'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Implement Edit User
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await userBox.deleteAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deleted')));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fetch and Display Vehicles from Hive
  Widget _buildVehicleManagementTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
      builder: (context, Box<Vehicle> vehicleBox, _) {
        if (vehicleBox.isEmpty) {
          return const Center(child: Text("No vehicles registered"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehicleBox.length,
                itemBuilder: (context, index) {
                  Vehicle? vehicle = vehicleBox.getAt(index);
                  return Card(
                    color: const Color(0xFF63D1F6),
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(
                          '${vehicle?.vehicleType} - ${vehicle?.licensePlate}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver: ${vehicle?.driverName}'),
                          Text('Registered at: ${vehicle?.timestamp}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Implement Edit Vehicle
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await vehicleBox.deleteAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vehicle deleted')));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fetch and Display Parking Slots from Hive with Add Option
  Widget _buildParkingSlotManagementTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ParkingSlot>('parkingSlots').listenable(),
      builder: (context, Box<ParkingSlot> parkingSlotBox, _) {
        if (parkingSlotBox.isEmpty) {
          return const Center(child: Text("No parking slots available"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parkingSlotBox.length,
                itemBuilder: (context, index) {
                  ParkingSlot? slot = parkingSlotBox.getAt(index);
                  return Card(
                    color: const Color(0xFFDEAF4B),
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    child: ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text('Slot: ${slot?.slotId}'),
                      subtitle: Text(
                          'Availability: ${slot?.isOccupied == true ? "Occupied" : "Available"}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Implement Edit Parking Slot
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Settings Tab for System Management
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: const Color(0xFF63D1F6),
            elevation: 4,
            shadowColor: Colors.grey[400],
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Role-Based Access Control'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement Role-Based Access Control Edit
                },
              ),
            ),
          ),
          Card(
            color: const Color(0xFF63D1F6),
            elevation: 4,
            shadowColor: Colors.grey[400],
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement Notification Settings Edit
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add Parking Slot Logic
  void _addParkingSlot() async {
    final slotController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Parking Slot'),
        content: TextField(
          controller: slotController,
          decoration: const InputDecoration(
            hintText: 'Enter Parking Slot ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without saving
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final slotId = slotController.text;

              if (slotId.isNotEmpty) {
                var parkingSlotBox = Hive.box<ParkingSlot>('parkingSlots');
                await parkingSlotBox.add(
                  ParkingSlot(slotId: slotId, isOccupied: false),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parking Slot Added Successfully')),
                );
              }
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Backup system data logic
  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System data backed up successfully!')),
    );
  }

  // Restore system data logic
  void _restoreData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System data restored successfully!')),
    );
  }
}
