import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  num get amountPaid => null!;

  bool get isPaid => null!;

  num get amount => null!;

  get date => null!;

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _couponController = TextEditingController();
  String selectedPaymentMethod = 'Credit/Debit Card';
  bool isPreAuthorized = false;
  double totalAmount = 50.0; // Example real-time charge

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Color(0xFF63D1F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Real-time Billing
            _buildSectionHeader('Real-time Billing'),
            _buildBillingSummary(),

            SizedBox(height: 16),
            // Section 2: Select Payment Method
            _buildSectionHeader('Select Payment Method'),
            _buildPaymentMethodSelector(),

            SizedBox(height: 16),
            // Section 3: Pre-authorize Payments
            _buildPreAuthorizeOption(),

            SizedBox(height: 16),
            // Section 4: Discounts and Promotions
            _buildSectionHeader('Discounts & Promotions'),
            _buildCouponField(),

            SizedBox(height: 24),
            // Payment Button
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF585D61),
      ),
    );
  }

  // Real-time Billing Summary
  Widget _buildBillingSummary() {
    return Card(
      color: Color(0xFF63D1F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This includes all charges for the current parking session.'),
          ],
        ),
      ),
    );
  }

  // Payment Method Selector
  Widget _buildPaymentMethodSelector() {
    return Card(
      color: Color(0xFFE8EAF6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPaymentMethodOption('Credit/Debit Card', Icons.credit_card),
            _buildPaymentMethodOption('Google Pay', Icons.account_balance_wallet),
            _buildPaymentMethodOption('Apple Pay', Icons.phone_iphone),
            _buildPaymentMethodOption('Online Wallet', Icons.account_balance),
          ],
        ),
      ),
    );
  }

  // Individual Payment Method Option
  Widget _buildPaymentMethodOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(method),
      trailing: Radio(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  // Pre-authorize Payment Option
  Widget _buildPreAuthorizeOption() {
    return Row(
      children: [
        Checkbox(
          value: isPreAuthorized,
          onChanged: (value) {
            setState(() {
              isPreAuthorized = value!;
            });
          },
        ),
        Text(
          'Pre-authorize future payments',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  // Coupon Field for Discounts and Promotions
  Widget _buildCouponField() {
    return Card(
      color: Color(0xFFDEAF4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply Coupon or Redeem Loyalty Points'),
            SizedBox(height: 8),
            TextFormField(
              controller: _couponController,
              decoration: InputDecoration(
                labelText: 'Enter Coupon Code',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    // Validate and apply coupon code
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pay Button
  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: () {
        _processPayment();
      },
      child: Text('Pay Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF63D1F6),
        textStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  // Dummy Payment Processing
  void _processPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Successful"),
        content: Text("Your payment of \$${totalAmount.toStringAsFixed(2)} was successful."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateInvoice();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Dummy Invoice Generation
  void _generateInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invoice generated and emailed to you.")),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
}
