import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ParkingTicket {
  final String ticketNumber;
  final String ownerName;
  final String vehicleType;
  final int slotId;
  bool isPaid;
  DateTime? checkOutTime;
  DateTime? issuedAt;

  ParkingTicket({
    required this.ticketNumber,
    required this.ownerName,
    required this.vehicleType,
    required this.slotId,
    required this.isPaid,
    this.checkOutTime,
    this.issuedAt,
  });
}

class CheckInCheckOutPage extends StatefulWidget {
  const CheckInCheckOutPage({Key? key}) : super(key: key);

  @override
  _CheckInCheckOutPageState createState() => _CheckInCheckOutPageState();
}

class _CheckInCheckOutPageState extends State<CheckInCheckOutPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ParkingTicket> tickets = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllParkingTickets();
  }

  Future<void> _fetchAllParkingTickets() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection('parkingTickets').get();
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
                ? DateTime.tryParse(data['checkOutTime'])
                : null,
            issuedAt: data['issuedAt'] != null
                ? DateTime.tryParse(data['issuedAt'])
                : null,
          );
        }).toList();

        // Sort tickets by issuedAt in descending order (most recent first)
        tickets.sort((a, b) {
          if (a.issuedAt == null) return 1; // Place tickets with null issuedAt last
          if (b.issuedAt == null) return -1;
          return b.issuedAt!.compareTo(a.issuedAt!); // Sort by issuedAt descending
        });
      });
    } catch (e) {
      print("Error fetching parking tickets: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _handleCheckIn(ParkingTicket ticket) async {
    DateTime now = DateTime.now();
    setState(() {
      ticket.issuedAt = now;
    });

    await _firestore
        .collection('parkingTickets')
        .doc(ticket.ticketNumber)
        .update({
      'issuedAt': now.toIso8601String(),
      'isPaid': ticket.isPaid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked in at ${_formatDateTime(now)}')),
    );
  }

  Future<void> _handleCheckOut(ParkingTicket ticket) async {
    DateTime now = DateTime.now();
    setState(() {
      ticket.checkOutTime = now;
    });

    await _firestore
        .collection('parkingTickets')
        .doc(ticket.ticketNumber)
        .update({
      'checkOutTime': now.toIso8601String(),
      'isPaid': ticket.isPaid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked out at ${_formatDateTime(now)}')),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                        Text('Check-in Time: ${_formatDateTime(ticket.issuedAt)}'),
                        Text('Check-out Time: ${_formatDateTime(ticket.checkOutTime)}'),
                        Text('Paid: ${ticket.isPaid ? "Yes" : "No"}'),
                      ],
                    ),
                    trailing: ticket.issuedAt == null
                        ? ElevatedButton(
                            onPressed: () => _handleCheckIn(ticket),
                            child: const Text('Check In'),
                          )
                        : ElevatedButton(
                            onPressed: ticket.checkOutTime == null
                                ? () => _handleCheckOut(ticket)
                                : null,
                            child: const Text('Check Out'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
