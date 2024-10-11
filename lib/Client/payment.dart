import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/Client/bookingConfirmed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String providerId;
  final String companyName;
  final List<String> services;
  final String address;
  final List<double> prices;
  final double totalPrice;

  const PaymentPage({
    super.key,
    required this.providerId,
    required this.companyName,
    required this.services,
    required this.address,
    required this.prices,
    required this.totalPrice,
    required List service,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  void showBookingSnackbar(BuildContext context, String bookingRef) {
    final snackBar = SnackBar(
      content: Text('Booking saved successfully with reference: $bookingRef'),
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<Map<String, String>> fetchClientData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userName = user.displayName ?? "Unknown User";
      String userId = user.uid;
      return {'userId': userId, 'userName': userName};
    }
    return {'userId': "unknown-user", 'userName': "Unknown User"};
  }

  Future<void> saveBookingDetails(
      String userId, String userName, BuildContext context) async {
    try {
      String bookingRef = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(bookingRef)
          .set({
        'userId': userId,
        'userName': userName,
        'serviceProviderId': widget.providerId,
        'companyName': widget.companyName,
        'services': widget.services,
        'address': widget.address,
        'prices': widget.prices,
        'totalPrice': widget.totalPrice,
        'date': DateTime.now(),
        'status': 'pending',
      });
      showBookingSnackbar(context, bookingRef);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving booking details')));
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    } else if (!RegExp(r'^\d{16}$').hasMatch(value)) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    } else if (!RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date (MM/YY)';
    } else if (!RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$').hasMatch(value)) {
      return 'Expiry date format must be MM/YY';
    } else {
      final now = DateTime.now();
      final parts = value.split('/');
      final month = int.parse(parts[0]);
      final year =
          int.parse(parts[1]) + 2000; // Assuming YY is in the range 00-99
      final expiryDate = DateTime(year, month);

      if (expiryDate.isBefore(now)) {
        return 'Expiry date must be in the future';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: fetchClientData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else {
            String userId = snapshot.data?['userId'] ?? "unknown-user";
            String userName = snapshot.data?['userName'] ?? "Unknown User";

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Company: ${widget.companyName}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Services: ${widget.services.join(", ")}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Address: ${widget.address}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Price: R${widget.prices.join(", ")}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Total: R${widget.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    const Text('Please enter your payment details below:',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 16,
                      keyboardType: TextInputType.number,
                      validator: _validateCardNumber,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: _validateCvv,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 5,
                      keyboardType: TextInputType.datetime,
                      validator: _validateExpiry,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await saveBookingDetails(userId, userName, context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Payment Successful!')),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BookingConfirmationPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[300],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child:
                          const Text('Pay Now', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
