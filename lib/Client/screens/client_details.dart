import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsPage extends StatelessWidget {
  final String appointmentId;

  const DetailsPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No details available.'));
          }
          var appointment = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reference: ${appointment['reference']}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Date: ${appointment['date']}'),
                const SizedBox(height: 16),
                Text('Client Name: ${appointment['clientName']}'),
                const SizedBox(height: 16),
                Text('Service: ${appointment['service']}'),
                // Add more fields as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
