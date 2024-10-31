// ignore_for_file: file_names, unused_import 

import 'package:finders_v1_1/Client/screens/appointment_page.dart';
import 'package:finders_v1_1/Client/screens/client_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/Reviews/reviewsPage.dart';
import 'package:flutter/material.dart';

class BookingConfirmationPage extends StatelessWidget {
  final String userId; // Assuming you pass userId to this page
  final String serviceProviderId; // Assuming you pass serviceProviderId to this page

  const BookingConfirmationPage({
    super.key,
    required this.userId,
    required this.serviceProviderId,
  });

  Future<String> fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['name']; // Adjust the field name if necessary
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return "Unknown User"; // Return a default value if the fetch fails
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Your booking has been confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientHomePage(
                              companyName: '',
                              providerId: '',
                              serviceProviderId: '',
                              address: '',
                              services: [],
                              clientId: '',
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[300],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text('Home', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16), // Add some space before the review button
              ElevatedButton(
                onPressed: () async {
                  String username = await fetchUserName(userId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        serviceProviderId: serviceProviderId,
                        clientId: userId,
                        username: username, // Pass the username here
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[300],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text('Leave a Review', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
