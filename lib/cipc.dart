// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Data Generator',
      home: Cipc(),
    );
  }
}

class Cipc extends StatelessWidget {
  final random = Random();

  Cipc({super.key});

  String generateRandomRegistrationNumber() {
    String number = '';
    for (int i = 0; i < 13; i++) {
      number += random.nextInt(10).toString();
    }
    return number;
  }

  DateTime generateRandomDateJoined() {
    int randomYear = 2015 + random.nextInt(9);
    int randomMonth = 1 + random.nextInt(12);
    int randomDay = 1 + random.nextInt(28);
    return DateTime(randomYear, randomMonth, randomDay);
  }

  String generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> addServiceProviderData() async {
    final CollectionReference serviceProviders =
        FirebaseFirestore.instance.collection('CIPC');

    List<String> companyNames = [
      'Tech Solutions',
      'Clean Sweep Services',
      'Pro Build Contractors',
      'Secure Guarding',
      'Green Landscaping',
      'Bright Future Tutoring',
      'Skyline Catering',
      'Rapid Movers',
      'Golden Plumbing',
      'Sparkle Electric'
    ];

    List<String> addresses = [
      '123 Main Street, Cityville',
      '456 Elm Avenue, Townsville',
      '789 Oak Street, Metropolis',
      '321 Pine Road, Villageton',
      '654 Maple Lane, Urbania',
    ];

    List<String> emails = [
      'info@techsolutions.com',
      'contact@cleansweep.com',
      'admin@probuild.com',
      'support@secureguarding.com',
      'hello@greenlandscaping.com',
      'info@brightfuture.com',
      'orders@skylinecatering.com',
      'bookings@rapidmovers.com',
      'service@goldenplumbing.com',
      'support@sparkleelectric.com',
    ];

    List<String> services = [
      'IT Solutions',
      'Cleaning Services',
      'Construction',
      'Security',
      'Landscaping',
      'Tutoring',
      'Catering',
      'Moving Services',
      'Plumbing',
      'Electrical'
    ];

    for (int i = 0; i < companyNames.length; i++) {
      await serviceProviders.add({
        'companyName': companyNames[i],
        'registrationNumber': generateRandomRegistrationNumber(),
        'address': addresses[random.nextInt(addresses.length)],
        'email': emails[i],
        'service': services[i],
        'dateJoined': generateRandomDateJoined(),
        'password': generateRandomPassword(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Random Data'),
      ),
      body: const Center(
        child: Text('Press the button to add random data to Firestore.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addServiceProviderData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Random data added to Firestore!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
