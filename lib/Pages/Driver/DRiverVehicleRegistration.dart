import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/vehicle.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For generating unique ticket ID

class ParkingVehicleRegistrationPage extends StatefulWidget {
  final int assignedSlotId; // Receive the assigned slot ID
  final String userEmail; // Receive the logged-in user's email

  const ParkingVehicleRegistrationPage({
    super.key,
    required this.assignedSlotId,
    required this.userEmail, // Add user email parameter
  });

  @override
  _ParkingVehicleRegistrationPageState createState() =>
      _ParkingVehicleRegistrationPageState();
}

class _ParkingVehicleRegistrationPageState extends State<ParkingVehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  // Method to register a vehicle
  Future<void> _registerVehicle() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique ticket ID
      String ticketId = _generateUniqueTicketId();

      // Get the assigned slot ID from the widget
      int assignedSlotId = widget.assignedSlotId;

      // Create new Vehicle object
      Vehicle newVehicle = Vehicle(
        driverName: _driverNameController.text,
        phone: _driverPhoneController.text,
        vehicleType: _vehicleTypeController.text,
        slotId: assignedSlotId,
        timestamp: DateTime.now(),
        licensePlate: _licensePlateController.text,
        vehicleColor: '',
        ticketId: ticketId,
        email: widget.userEmail, // Save the user's email
      );

      // Save vehicle to Hive
      var vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      await vehicleBox.add(newVehicle);

      // Mark the parking slot as occupied
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      ParkingSlot? selectedParkingSlot = parkingSlotBox.get(assignedSlotId);

      if (selectedParkingSlot != null) {
        // Check if the slot is already occupied
        if (!selectedParkingSlot.isOccupied) {
          // Mark as occupied
          selectedParkingSlot.isOccupied = true;
          selectedParkingSlot.checkInTime = DateTime.now(); // Set check-in time
          selectedParkingSlot.ownerName = _driverNameController.text; // Set owner name
          selectedParkingSlot.vehicleDetails = newVehicle.vehicleType; // Set vehicle details

          // Save updated parking slot to Hive
          await parkingSlotBox.put(assignedSlotId, selectedParkingSlot);

          // Update Firestore for the corresponding parking slot
          await _firestore
              .collection('parkingSlots')
              .doc(assignedSlotId.toString())
              .set(
            {
              'slotId': selectedParkingSlot.slotId,
              'isOccupied': selectedParkingSlot.isOccupied,
              'checkInTime': selectedParkingSlot.checkInTime?.toIso8601String(),
              'checkOutTime': selectedParkingSlot.checkOutTime?.toIso8601String(),
              'vehicleDetails': selectedParkingSlot.vehicleDetails,
              'ownerName': selectedParkingSlot.ownerName,
              'addedTime': selectedParkingSlot.addedTime?.toIso8601String(),
            },
            SetOptions(merge: true),
          );

          // Save ticket information to Firestore
          await _firestore.collection('parkingTickets').doc(ticketId).set({
            'ticketId': ticketId,
            'slotId': assignedSlotId,
            'vehicleType': newVehicle.vehicleType,
            'licensePlate': newVehicle.licensePlate,
            'ownerName': newVehicle.driverName,
            'email': widget.userEmail, // Save the user's email
            'timestamp': DateTime.now().toIso8601String(),
            'isPaid': false, // Initial payment status
          });

          // Clear form
          _clearForm();

          // Show confirmation with the unique ticket ID
          _showConfirmationDialog(ticketId);
        } else {
          // Handle the case where the slot is already occupied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected parking slot is already occupied!')),
          );
        }
      } else {
        // Handle the case where the slot is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected parking slot not found!')),
        );
      }
    }
  }

  // Generate a unique ticket ID
  String _generateUniqueTicketId() {
    var random = Random();
    return 'TKT-${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  // Method to clear form fields
  void _clearForm() {
    _driverNameController.clear();
    _driverPhoneController.clear();
    _vehicleTypeController.clear();
    _licensePlateController.clear();
  }

  // Confirmation Dialog with print ticket option
  void _showConfirmationDialog(String ticketId) {
    if (!mounted) return; // Check if the widget is still mounted

    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Vehicle Registered Successfully"),
          content: Text(
              "Your ticket ID is $ticketId.\nDo you want to print the parking ticket?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _printTicket(); // Call the print ticket function
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Just dismiss the dialog
              },
              child: const Text("No"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error displaying confirmation dialog: $e"); // Log the error
    }
  }

  // Dummy method for printing ticket
  void _printTicket() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parking ticket printed successfully")),
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Registration'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Driver Name
              TextFormField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Driver Phone
              TextFormField(
                controller: _driverPhoneController,
                decoration: InputDecoration(
                  labelText: 'Driver Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver\'s phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Type
              TextFormField(
                controller: _vehicleTypeController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Register Vehicle Button
              ElevatedButton(
                onPressed: _registerVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: const Color(0xFF63D1F6),
                  textStyle: const TextStyle(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Register Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
