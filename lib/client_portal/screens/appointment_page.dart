// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firebase

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool isRecentSelected = true; // Toggle between recent and history

  // Function to fetch recent appointments
  Stream<QuerySnapshot> fetchRecentAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('clientId', isEqualTo: 'your-client-id') // Filter by client ID
        .where('status', isEqualTo: 'recent') // Example filter for recent
        .snapshots();
  }

  // Function to fetch appointment history
  Stream<QuerySnapshot> fetchAppointmentHistory() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('clientId', isEqualTo: 'your-client-id')
        .where('status', isEqualTo: 'completed') // Example filter for history
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text('Appointments'),
      //   backgroundColor: Colors.blue,
      // ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isRecentSelected = true;
                  });
                },
                child: const Text('Recent Requests'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isRecentSelected = false;
                  });
                },
                child: const Text('History'),
              ),
            ],
          ),
          Expanded(
            child: isRecentSelected
                ? buildAppointmentList(fetchRecentAppointments())
                : buildAppointmentList(fetchAppointmentHistory()),
          ),
        ],
      ),
    );
  }

  // Widget to build the list of appointments
  Widget buildAppointmentList(Stream<QuerySnapshot> appointmentStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: appointmentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot appointment = snapshot.data!.docs[index];
            return Card(
              child: ListTile(
                title: Text('Reference: ${appointment['reference']}'),
                subtitle: Text('Date: ${appointment['date']}'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/detailsPage',
                      arguments: appointment.id, // Pass appointment ID
                    );
                  },
                  child: const Text('Details'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
