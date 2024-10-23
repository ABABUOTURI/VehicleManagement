import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/models/parking_ticket.dart'; // Import your ParkingTicket model

class CheckParkingTicketsPage extends StatefulWidget {
  const CheckParkingTicketsPage({super.key});

  @override
  _CheckParkingTicketsPageState createState() =>
      _CheckParkingTicketsPageState();
}

class _CheckParkingTicketsPageState extends State<CheckParkingTicketsPage> {
  final TextEditingController _ticketNumberController =
      TextEditingController(); // Controller for inputting ticket number
  ParkingTicket? ticket; // Store the ticket data
  bool ticketFound = false; // Track if a ticket was found

  // Method to fetch parking ticket data from Hive
  Future<void> _fetchTicketDetails() async {
    if (_ticketNumberController.text.isNotEmpty) {
      var ticketBox = await Hive.openBox<ParkingTicket>('parkingTickets');

      final foundTicket = ticketBox.values.firstWhere(
        (t) => t.ticketNumber == _ticketNumberController.text,
        orElse: () => null!,
      );

      setState(() {
        ticket = foundTicket;
        ticketFound = foundTicket != null;
      });
    }
  }

  // Method to issue a fine for overdue or unpaid parking
  void _issueFine() {
    // Add logic to issue a fine (this can be updated to include actual fine logic)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fine issued successfully')),
    );
  }

  @override
  void dispose() {
    _ticketNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Parking Tickets'),
        backgroundColor: const Color(0xFF63D1F6), // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Ticket Number Input Field
            TextFormField(
              controller: _ticketNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Ticket Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
            ),
            const SizedBox(height: 16),

            // Button to Fetch Ticket Details
            ElevatedButton(
              onPressed: _fetchTicketDetails,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: const Color(0xFF63D1F6),
                textStyle: const TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Check Ticket'),
            ),
            const SizedBox(height: 24),

            // Display ticket details if found
            if (ticketFound)
              Card(
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
                        'Ticket Number: ${ticket?.ticketNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${ticket?.isPaid == true ? 'Paid' : 'Unpaid'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: ticket?.isPaid == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Vehicle Type: ${ticket?.vehicleType}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Parking Slot: ${ticket?.slotId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Button to Issue Fine if the ticket is unpaid or overdue
                      if (ticket?.isPaid == false)
                        ElevatedButton(
                          onPressed: _issueFine,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Issue Fine'),
                        ),
                    ],
                  ),
                ),
              ),
            if (!ticketFound && _ticketNumberController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No ticket found for the entered number.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
