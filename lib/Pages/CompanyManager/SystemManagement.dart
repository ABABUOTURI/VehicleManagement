import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore integration
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:flutter/services.dart';

class SystemManagementPage extends StatefulWidget {
  const SystemManagementPage({super.key});

  @override
  _SystemManagementPageState createState() => _SystemManagementPageState();
}

class _SystemManagementPageState extends State<SystemManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showFloatingButton = false; // For toggling the FloatingActionButton
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          showFloatingButton =
              _tabController.index == 1; // Show on "Parking Slots" tab
        });
      }
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
          _buildParkingSlotManagementTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              onPressed: _addParkingSlot,
              backgroundColor: const Color(0xFF63D1F6),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Build User Management Tab
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
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('User deleted')));
                              }
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

  // Build Parking Slot Management Tab
  Widget _buildParkingSlotManagementTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ParkingSlot>('parkingSlots').listenable(),
      builder: (context, Box<ParkingSlot> parkingSlotBox, _) {
        if (parkingSlotBox.isEmpty) {
          return const Center(child: Text("No parking slots available"));
        }

        List<ParkingSlot> parkingSlots = parkingSlotBox.values.toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parkingSlots.length,
                itemBuilder: (context, index) {
                  ParkingSlot? slot = parkingSlots[index];
                  return Card(
                    color: slot.isOccupied
                        ? Colors.green[300]
                        : const Color(0xFFDEAF4B),
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    child: ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text('Slot: ${slot.slotId}'),
                      subtitle: Text(
                          'Availability: ${slot.isOccupied ? "Occupied" : "Available"}'),
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

  // Build Settings Tab
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
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Enter Parking Slot ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (slotController.text.isNotEmpty) {
                final slotId = int.tryParse(slotController.text.trim());
                if (slotId != null) {
                  var parkingSlotBox = Hive.box<ParkingSlot>('parkingSlots');
                  bool slotExists = parkingSlotBox.values
                      .any((slot) => slot.slotId == slotId);

                  if (!slotExists) {
                    ParkingSlot newSlot = ParkingSlot(
                      slotId: slotId,
                      isOccupied: false,
                      addedTime: DateTime.now(),
                    );

                    // Save to Hive
                    await parkingSlotBox.add(newSlot);

                    try {
                      // Save to Firestore
                      await _firestore
                          .collection('parkingSlots')
                          .doc(slotId.toString())
                          .set({
                        'slotId': newSlot.slotId,
                        'isOccupied': newSlot.isOccupied,
                        'checkInTime': newSlot.checkInTime?.toIso8601String(),
                        'checkOutTime': newSlot.checkOutTime?.toIso8601String(),
                        'vehicleDetails': newSlot.vehicleDetails,
                        'ownerName': newSlot.ownerName,
                        'addedTime': newSlot.addedTime?.toIso8601String(),
                      });
                      print('Parking slot successfully saved to Firestore');
                    } catch (e) {
                      print('Failed to save parking slot to Firestore: $e');
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Parking Slot Added Successfully')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Slot ID already exists')),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid slot ID')),
                    );
                  }
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Backup system data logic
  void _backupData() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System data backed up successfully!')),
      );
    }
  }

  // Restore system data logic
  void _restoreData() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System data restored successfully!')),
      );
    }
  }
}
