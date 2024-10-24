import 'package:finders_v1_1/Client/screens/appointment_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String
      appointmentReference; // Document ID passed from the previous page.

  const ServiceDetailsPage({super.key, required this.appointmentReference});

  Future<DocumentSnapshot> _fetchAppointmentDetails() async {
    return await FirebaseFirestore.instance
        .collection('appointments')
        .doc(
            appointmentReference) // Fetch document using the passed document ID.
        .get();
  }

  // Function to show confirmation dialog before canceling
  Future<void> _showConfirmationDialog(
      BuildContext context, String status) async {
    if (status == 'pending') {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap button for close dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Cancellation'),
            content:
                const Text('Are you sure you want to cancel this appointment?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentPage(),
                    ),
                  ); // Close the dialog and go to previous page
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _cancelAppointment(context); // Proceed to cancel appointment
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot cancel a confirmed appointment')),
      );
    }
  }

  // Function to cancel the appointment
  Future<void> _cancelAppointment(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentReference)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment canceled successfully')),
      );

      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error canceling appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchAppointmentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching details'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No details found'));
          }

          var appointmentData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract fields
          String companyName = appointmentData['companyName'] ?? 'N/A';
          String status = appointmentData['status'] ?? 'N/A';
          String userId = appointmentData['userId'] ?? 'N/A';
          String address = appointmentData['address'] ?? 'N/A';
          Timestamp date = appointmentData['date'];

          // Handle 'services' as a List
          var services = appointmentData['services'];
          String servicesText = services is List ? services.join(', ') : 'N/A';

          // Handle 'quantities' as a List
          var quantities = appointmentData['quantities'] ?? [];
          String quantitiesText =
              quantities is List ? quantities.join(', ') : 'N/A';

          // Handle totalPrice as either int or double
          double? totalPrice;
          if (appointmentData['totalPrice'] is int) {
            totalPrice = (appointmentData['totalPrice'] as int).toDouble();
          } else {
            totalPrice = appointmentData['totalPrice'] as double?;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reference: $appointmentReference'),
                const SizedBox(height: 10),
                Text('Date: ${date.toDate()}'),
                const SizedBox(height: 10),
                Text('Client ID: $userId'),
                const SizedBox(height: 10),
                Text('Company Name: $companyName'),
                const SizedBox(height: 10),
                Text('Service(s): $servicesText'),
                const SizedBox(height: 10),
                Text('Quantities: $quantitiesText',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Amount: ${totalPrice != null ? 'R$totalPrice' : 'N/A'}'),
                const SizedBox(height: 10),
                Text('Status: $status'),
                const SizedBox(height: 10),
                Text('Address: $address'),
                const SizedBox(height: 40),
                // if (status == 'pending') ...[
                //   ElevatedButton(
                //     onPressed: () => _showConfirmationDialog(context, status),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.red, // Red color for cancel
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 30, vertical: 10),
                //     ),
                //     child: const Text('Cancel Appointment',
                //         style: TextStyle(fontSize: 16)),
                //   ),
                // ],
              ],
            ),
          );
        },
      ),
    );
  }
}
