import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:vehicle/models/parking_slot.dart';

class CheckInCheckOutPage extends StatefulWidget {
  final int? initialSlotId; // New parameter for initial slot ID to handle automatic check-in
  final DateTime? initialCheckInTime; // New parameter for initial check-in time

  const CheckInCheckOutPage({super.key, this.initialSlotId, this.initialCheckInTime});

  @override
  _CheckInCheckOutPageState createState() => _CheckInCheckOutPageState();
}

class _CheckInCheckOutPageState extends State<CheckInCheckOutPage> {
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckedIn = false;
  bool isCheckoutApproved = false; // To track if the parking attendant has approved checkout
  ParkingSlot? currentSlot;

  @override
  void initState() {
    super.initState();
    _loadCurrentSlot();
    if (widget.initialSlotId != null && widget.initialCheckInTime != null) {
      _handleAutomaticCheckIn(widget.initialSlotId!, widget.initialCheckInTime!);
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

  void _handleAutomaticCheckIn(int slotId, DateTime initialCheckInTime) async {
    var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
    ParkingSlot? slot = parkingSlotBox.get(slotId);

    if (slot != null && !slot.isOccupied) {
      setState(() {
        currentSlot = slot;
        checkInTime = initialCheckInTime;
        isCheckedIn = true;
      });

      // Update the slot's check-in status in Hive
      slot.isOccupied = true;
      slot.checkInTime = checkInTime;
      await parkingSlotBox.put(slotId, slot);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked in to slot ${slot.slotId} automatically')),
      );
    }
  }

  void _handleCheckIn() {
    if (currentSlot != null) {
      setState(() {
        checkInTime = DateTime.now();
        isCheckedIn = true;
        currentSlot!.checkInTime = checkInTime; // Update the slot's check-in time
      });
      _updateSlotInHive();
    }
  }

  Future<void> _handleCheckOut() async {
    if (!isCheckoutApproved) {
      _showApprovalRequiredMessage();
      return;
    }

    setState(() {
      checkOutTime = DateTime.now();
      isCheckedIn = false;
    });
    await _removeBooking();
    _showCheckOutSummary();
  }

  Future<void> _updateSlotInHive() async {
    if (currentSlot != null) {
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      await parkingSlotBox.put(currentSlot!.slotId, currentSlot!);
    }
  }

  Future<void> _removeBooking() async {
    if (currentSlot != null) {
      var parkingSlotBox = await Hive.openBox<ParkingSlot>('parkingSlots');
      currentSlot!.isOccupied = false;
      currentSlot!.checkInTime = null; // Clear the check-in time
      await parkingSlotBox.put(currentSlot!.slotId, currentSlot!);
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
        builder: (context) => AlertDialog(
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
        ),
      );
    }
  }

  double _calculateBill(Duration timeSpent) {
    double hourlyRate = 5.0; // Example rate per hour
    return (timeSpent.inMinutes / 60) * hourlyRate;
  }

  void _showApprovalRequiredMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approval Required"),
        content: const Text(
            "Check-out is not allowed until it has been approved by the parking attendant."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
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
            // Section: Parking Slot Status
            Card(
              color: const Color(0xFF63D1F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckedIn
                          ? 'Checked-in at: ${_formatDateTime(checkInTime)}'
                          : currentSlot != null && currentSlot!.isOccupied
                              ? 'Slot ${currentSlot!.slotId} is currently occupied. Checked in at: ${_formatDateTime(checkInTime)}'
                              : 'No active booking.',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (isCheckedIn)
                      ElevatedButton(
                        onPressed: _handleCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        child: const Text('Check-out'),
                      )
                    else if (currentSlot != null && currentSlot!.isOccupied)
                      ElevatedButton(
                        onPressed: _handleCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        child: const Text('Check-in'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section: Time Tracking
            _buildSectionHeader('Time Tracking'),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF63D1F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in Time: ${_formatDateTime(checkInTime)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check-out Time: ${_formatDateTime(checkOutTime)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (checkInTime != null && checkOutTime != null)
                      Text(
                        'Time spent: ${checkOutTime!.difference(checkInTime!).inMinutes} minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
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
