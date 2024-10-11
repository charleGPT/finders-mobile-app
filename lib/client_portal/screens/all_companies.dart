import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllCompaniesPage extends StatelessWidget {
  const AllCompaniesPage({super.key});

  // Fetch service providers from Firestore
  Stream<QuerySnapshot> getServiceProviders() {
    return FirebaseFirestore.instance
        .collection('Service Provider')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: getServiceProviders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final serviceProviders = snapshot.data!.docs;

          if (serviceProviders.isEmpty) {
            return const Center(child: Text('No service providers found.'));
          }

          return ListView.builder(
            itemCount: serviceProviders.length,
            itemBuilder: (context, index) {
              var serviceProvider = serviceProviders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const CircleAvatar(
                      //backgroundImage: NetworkImage(
                      // serviceProvider['profilePictureUrl'] ??
                      //   'https://via.placeholder.com/150',
                      //),
                      ),
                  title: Text(serviceProvider['companyName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service: ${serviceProvider['service']}'),
                      Text('Email: ${serviceProvider['email']}'),
                      Text('Address: ${serviceProvider['address']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      // Optional: Navigate to a detailed company page if needed
                      Navigator.pushNamed(context, '/bookingPage');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
