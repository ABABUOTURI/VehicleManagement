import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ParkingTicket model class
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

class CheckParkingTicketsPage extends StatefulWidget {
  const CheckParkingTicketsPage({super.key});

  @override
  _CheckParkingTicketsPageState createState() =>
      _CheckParkingTicketsPageState();
}

class _CheckParkingTicketsPageState extends State<CheckParkingTicketsPage> {
  List<ParkingTicket> tickets = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllTickets(); // Fetch all tickets on initialization
  }

  // Method to fetch all parking tickets from Firestore
  Future<void> _fetchAllTickets() async {
    setState(() {
      loading = true; // Start loading
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('parkingTickets').get();
      List<ParkingTicket> fetchedTickets = snapshot.docs.map((doc) {
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
      }).toList();

      setState(() {
        tickets = fetchedTickets; // Update tickets list
      });
    } catch (e) {
      print("Failed to fetch tickets: $e");
    } finally {
      setState(() {
        loading = false; // Stop loading
      });
    }
  }

  // Method to accept checkout
  Future<void> _acceptCheckout(ParkingTicket ticket) async {
    ticket.isPaid = true; // Mark ticket as paid
    ticket.checkOutTime = DateTime.now(); // Set the checkout time

    // Update the ticket in Firestore
    await _firestore.collection('parkingTickets').doc(ticket.ticketNumber).set({
      'isPaid': ticket.isPaid,
      'checkOutTime': ticket.checkOutTime?.toIso8601String(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout accepted.')),
    );
    setState(() {
      tickets.remove(ticket); // Remove the ticket from the list
    });
  }

  // Method to deny checkout
  void _denyCheckout(ParkingTicket ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout denied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Parking Tickets'),
        backgroundColor: const Color(0xFF63D1F6), // AppBar background color
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  ParkingTicket ticket = tickets[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Number: ${ticket.ticketNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Owner Name: ${ticket.ownerName}', // Display owner's name
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Status: ${ticket.isPaid ? 'Paid' : 'Unpaid'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: ticket.isPaid ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Vehicle Type: ${ticket.vehicleType}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Parking Slot: ${ticket.slotId}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          // Buttons for Accept and Deny Checkout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => _acceptCheckout(ticket),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  backgroundColor: Colors.green,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Accept Checkout'),
                              ),
                              ElevatedButton(
                                onPressed: () => _denyCheckout(ticket),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  backgroundColor: Colors.red,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Deny Checkout'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}