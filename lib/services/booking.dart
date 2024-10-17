// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:finders_v1_1/services/firestore_service.dart';
import 'package:flutter/material.dart';
//import 'package:finders_v1_1/services/firestore_service.dart'; // Corrected import path

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controllers to handle user input
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  // Placeholder for service provider ID - should be dynamically fetched
  String serviceProviderId = "defaultProviderId";

  // Example function to book appointment
  void _bookAppointment() async {
    // Ensure price input is a valid integer
    int? price = int.tryParse(_priceController.text);
    if (price == null) {
      print('Invalid price format');
      return;
    }

    // Ensure other fields are not empty
    if (_addressController.text.isEmpty ||
        _companyNameController.text.isEmpty ||
        _serviceController.text.isEmpty ||
        serviceProviderId.isEmpty) {
      print('Please fill out all fields');
      return;
    }

    // Call the Firestore service to create the appointment
    await _firestoreService.createAppointment(
      address: _addressController.text,
      companyName: _companyNameController.text,
      date: DateTime.now(), // Use current date for simplicity
      price: price,
      service: _serviceController.text,
      serviceProviderId:
          serviceProviderId, // Must be fetched based on your app logic
      userName: 'Unknown User', // Replace with actual user name if available
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Address input field
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            // Company name input field
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            // Price input field
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType:
                  TextInputType.number, // Ensure only numbers are input
            ),
            // Service input field
            TextField(
              controller: _serviceController,
              decoration: InputDecoration(labelText: 'Service'),
            ),
            SizedBox(height: 20),
            // Book Appointment button
            ElevatedButton(
              onPressed: _bookAppointment, // Trigger booking function on press
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _addressController.dispose();
    _companyNameController.dispose();
    _priceController.dispose();
    _serviceController.dispose();
    super.dispose();
  }
}
