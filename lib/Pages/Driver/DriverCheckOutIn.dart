import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/parking_ticket.dart'; // Import ParkingTicket model
class ParkingTicket {
  final String ticketNumber; // Immutable
  final String ownerName; // Immutable
  final String vehicleType; // Immutable
  final int slotId; // Immutable
  bool isPaid; // Mutable, can change its value
  DateTime? checkOutTime; // Nullable and mutable, can be set later
  DateTime? issuedAt; // Nullable, can be set later

  // Constructor
  ParkingTicket({
    required this.ticketNumber,
    required this.ownerName,
    required this.vehicleType,
    required this.slotId,
    required this.isPaid,
    this.checkOutTime, // Nullable parameter
    this.issuedAt, // Nullable parameter
  });
}


class CheckInCheckOutPage extends StatefulWidget {
  final int? initialSlotId; // Parameter for initial slot ID
  final DateTime? initialCheckInTime; // Parameter for initial check-in time

  const CheckInCheckOutPage(
      {super.key, this.initialSlotId, this.initialCheckInTime});

  @override
  _CheckInCheckOutPageState createState() => _CheckInCheckOutPageState();
}

class _CheckInCheckOutPageState extends State<CheckInCheckOutPage> {
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckedIn = false;
  ParkingSlot? currentSlot;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ParkingTicket> tickets = []; // List to hold all parking tickets
  bool loading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _loadCurrentSlot();
    _fetchAllParkingTickets(); // Fetch all tickets when the page loads
    if (widget.initialSlotId != null && widget.initialCheckInTime != null) {
      _handleAutomaticCheckIn(
          widget.initialSlotId!, widget.initialCheckInTime!);
    }
  }

  Future<void> _loadCurrentSlot() async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    var occupiedSlots = parkingSlotBox.values
        .where((slot) => slot.isOccupied)
        .cast<ParkingSlot>()
        .toList();
    if (occupiedSlots.isNotEmpty) {
      setState(() {
        currentSlot = occupiedSlots.first;
        checkInTime = currentSlot?.checkInTime;
        isCheckedIn = checkInTime != null;
      });
    }
  }

  Future<void> _fetchAllParkingTickets() async {
    setState(() {
      loading = true; // Start loading
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('parkingTickets').get();
      setState(() {
        tickets = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return ParkingTicket(
            ticketNumber: data['ticketId'],
            ownerName: data['ownerName'],
            vehicleType: data['vehicleType'],
            slotId: data['slotId'],
            isPaid: data['isPaid'] ?? false,
            checkOutTime: data['checkOutTime'] != null
                ? DateTime.tryParse(
                    data['checkOutTime']) // Use tryParse for safety
                : null,
            issuedAt: data['issuedAt'] != null
                ? DateTime.tryParse(data['issuedAt']) // Use tryParse for safety
                : null,
          );
        }).toList(); // Update tickets list
      });
    } catch (e) {
      print("Error fetching parking tickets: $e");
    } finally {
      setState(() {
        loading = false; // Stop loading
      });
    }
  }

  Future<void> _handleCheckOut(ParkingTicket ticket) async {
    if (currentSlot == null) {
      _showErrorMessage("No active booking found.");
      return;
    }

    if (!ticket.isPaid) {
      _showErrorMessage(
          "Checkout not allowed. Please ensure the ticket is paid.");
      return;
    }

    if (ticket.checkOutTime != null) {
      _showErrorMessage(
          "Checkout not allowed. This ticket has already been checked out.");
      return;
    }

    setState(() {
      checkOutTime = DateTime.now();
      isCheckedIn = false;
    });

    await _removeBooking();
    _showCheckOutSummary();
  }

  Future<void> _removeBooking() async {
    if (currentSlot != null) {
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      currentSlot!.isOccupied = false;
      currentSlot!.checkInTime = null; // Clear the check-in time
      await parkingSlotBox.put(currentSlot!.slotId, currentSlot!);
      await _updateSlotInFirestore(); // Also update Firestore to mark as unoccupied
    }
  }

  Future<void> _updateSlotInFirestore() async {
    if (currentSlot != null) {
      await _firestore
          .collection('parkingSlots')
          .doc(currentSlot!.slotId.toString())
          .set({
        'isOccupied': currentSlot!.isOccupied,
        'checkInTime': currentSlot!.checkInTime?.toIso8601String(),
        'checkOutTime': checkOutTime?.toIso8601String(),
        'ownerName': currentSlot!.ownerName,
        'vehicleDetails': currentSlot!.vehicleDetails,
      }, SetOptions(merge: true));
    }
  }

  void _showCheckOutSummary() {
    if (checkInTime != null && checkOutTime != null) {
      Duration timeSpent = checkOutTime!.difference(checkInTime!);
      double billAmount = _calculateBill(timeSpent);

      String formattedTimeSpent =
          "${timeSpent.inHours} hours, ${timeSpent.inMinutes % 60} minutes";

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Check-out Successful"),
            content: Text(
                "You have parked for $formattedTimeSpent.\nTotal bill: Ksh${billAmount.toStringAsFixed(2)}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Check-in or Check-out time is not valid.")));
    }
  }

  double _calculateBill(Duration timeSpent) {
    double hourlyRate = 5.0; // Example rate per hour
    return (timeSpent.inMinutes / 60) * hourlyRate;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  void _handleAutomaticCheckIn(int slotId, DateTime initialCheckInTime) async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    ParkingSlot? slot = parkingSlotBox.get(slotId);

    if (slot != null && !slot.isOccupied) {
      setState(() {
        currentSlot = slot;
        checkInTime = initialCheckInTime;
        isCheckedIn = true;
      });

      slot.isOccupied = true;
      slot.checkInTime = checkInTime;
      await parkingSlotBox.put(slotId, slot);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Checked in to slot ${slot.slotId} automatically')));
    }
  }

  Future<void> _confirmCheckout(ParkingTicket ticket) async {
    // Remove ticket from Firestore
    await _firestore
        .collection('parkingTickets')
        .doc(ticket.ticketNumber)
        .delete();

    // Free the associated parking slot
    await _firestore
        .collection('parkingSlots')
        .doc(ticket.slotId.toString())
        .set({
      'isOccupied': false,
      'checkInTime': null,
      'checkOutTime': null,
      // Add any additional fields as necessary
    }, SetOptions(merge: true));

    // Optionally remove from the tickets list and update UI
    setState(() {
      tickets.remove(ticket);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket has been confirmed and removed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in / Check-out'),
        backgroundColor: const Color(0xFF63D1F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Display Check-in Time
            if (checkInTime != null)
              Text(
                'Check-in Time: ${_formatDateTime(checkInTime)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),

            // Section: Display All Parking Tickets
            _buildSectionHeader('Parking Tickets'),
            const SizedBox(height: 8),
            loading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      ParkingTicket ticket = tickets[index];
                      return Card(
                        color: const Color(0xFF63D1F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('Ticket ID: ${ticket.ticketNumber}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Owner: ${ticket.ownerName}'),
                              Text('Vehicle: ${ticket.vehicleType}'),
                              Text('Slot ID: ${ticket.slotId}'),
                              Text(
                                  'Check-in Time: ${_formatDateTime(ticket.issuedAt)}'),
                              Text('Paid: ${ticket.isPaid ? "Yes" : "No"}'),
                            ],
                          ),
                          trailing: ticket.isPaid
                              ? ElevatedButton(
                                  onPressed: () => _confirmCheckout(ticket),
                                  child: const Text('Confirm'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .green, // Green color for confirm button
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _handleCheckOut(ticket),
                                  child: const Text('Checkout'),
                                ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

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
}
