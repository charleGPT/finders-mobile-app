// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth

class ServiceProviderAppointmentPage extends StatefulWidget {
  const ServiceProviderAppointmentPage({super.key});

  @override
  _ServiceProviderAppointmentPageState createState() =>
      _ServiceProviderAppointmentPageState();
}

class _ServiceProviderAppointmentPageState
    extends State<ServiceProviderAppointmentPage> {
  bool isRecentSelected = true; // Toggle between recent and history

  // Fetch recent (pending) appointments for the service provider
  Stream<QuerySnapshot> fetchRecentAppointments(String providerId) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('serviceProviderId', isEqualTo: providerId) // Filter by provider
        .where('status', isEqualTo: 'pending') // Only show pending bookings
        .snapshots();
  }

  // Fetch accepted/rejected appointments for the service provider (history)
  Stream<QuerySnapshot> fetchAppointmentHistory(String providerId) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('serviceProviderId', isEqualTo: providerId) // Filter by provider
        .where('status', whereIn: [
      'accepted',
      'rejected'
    ]) // History of accepted/rejected bookings
        .snapshots();
  }

  // Update booking status to 'accepted' or 'rejected'
  Future<void> updateBookingStatus(String appointmentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': status}); // Update the appointment status
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating booking status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? providerId =
        FirebaseAuth.instance.currentUser?.uid; // Get provider's ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: Column(
        children: [
          // Toggle buttons for Recent and History
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
          // Display the appointment list based on the toggle
          Expanded(
            child: providerId != null
                ? (isRecentSelected
                    ? buildAppointmentList(
                        fetchRecentAppointments(providerId), true)
                    : buildAppointmentList(
                        fetchAppointmentHistory(providerId), false))
                : const Center(child: Text('User not logged in')),
          ),
        ],
      ),
    );
  }

  // Widget to build the list of appointments
  Widget buildAppointmentList(
      Stream<QuerySnapshot> appointmentStream, bool isPending) {
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
                title: Text('Reference: ${appointment.id}'),
                subtitle: Text(
                  'Date: ${appointment['date'].toDate().toString()}\n'
                  'Service: ${appointment['service']}\n'
                  'Client: ${appointment['userName']}',
                ),
                trailing: isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              updateBookingStatus(appointment.id, 'accepted');
                            },
                            child: const Text('Accept'),
                          ),
                          TextButton(
                            onPressed: () {
                              updateBookingStatus(appointment.id, 'rejected');
                            },
                            child: const Text('Reject'),
                          ),
                        ],
                      )
                    : Text('Status: ${appointment['status']}'),
              ),
            );
          },
        );
      },
    );
  }
}
