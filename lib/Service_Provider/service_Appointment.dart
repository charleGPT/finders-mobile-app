import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firebase
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase Auth

class ServiceProviderAppointmentPage extends StatefulWidget {
  const ServiceProviderAppointmentPage(
      {super.key, required String companyName});

  @override
  _ServiceProviderAppointmentPageState createState() =>
      _ServiceProviderAppointmentPageState();
}

class _ServiceProviderAppointmentPageState
    extends State<ServiceProviderAppointmentPage> {
  bool isRecentSelected = true; // Toggle between recent and history
  String? companyName; // Variable to hold company name

  // Fetch the current user's data
  Future<void> fetchProviderData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Fetch company name from Firestore
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection(
              'Service Provider') // Assuming you have a serviceProviders collection
          .doc(userId)
          .get();

      if (providerDoc.exists && providerDoc.data() != null) {
        var data = providerDoc.data() as Map<String, dynamic>;
        setState(() {
          companyName = data['companyName'] ?? "Unknown Company";
        });
      } else {
        setState(() {
          companyName = "Unknown Company";
        });
      }
    }
  }

  // Function to fetch recent (pending) appointments for the service provider
  Stream<QuerySnapshot> fetchRecentAppointments() {
    print('Fetching recent appointments for company: $companyName'); // Debug
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('companyName', isEqualTo: companyName) // Filter by company name
        .where('status', isEqualTo: 'pending') // Show only pending appointments
        .snapshots();
  }

  // Function to fetch appointment history (accepted/rejected) for the service provider
  Stream<QuerySnapshot> fetchAppointmentHistory() {
    print('Fetching appointment history for company: $companyName'); // Debug
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('companyName', isEqualTo: companyName) // Filter by company name
        .where('status', whereIn: [
      'accepted',
      'rejected'
    ]) // Show accepted/rejected bookings
        .snapshots();
  }

  // Function to update booking status to 'accepted' or 'rejected'
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
  void initState() {
    super.initState();
    fetchProviderData(); // Fetch the provider data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Appointments'),
        backgroundColor: Colors.blueAccent[100],
      ),
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
            child: companyName != null
                ? (isRecentSelected
                    ? buildAppointmentList(fetchRecentAppointments(), true)
                    : buildAppointmentList(fetchAppointmentHistory(), false))
                : const Center(child: Text('Loading company information...')),
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
                title: Text(
                    'Reference: ${appointment.id}'), // Use appointment ID as reference
                subtitle: Text(
                  'Date: ${appointment['date'].toDate().toString()}\n'
                  'Service: ${appointment['services'].join(", ")}\n'
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
