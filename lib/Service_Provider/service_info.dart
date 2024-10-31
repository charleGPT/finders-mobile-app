// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceProviderDetailsPage extends StatefulWidget {
  final String companyName;
  final String serviceProviderId;
  final String address;
  final List<String> services;

  const ServiceProviderDetailsPage({
    Key? key,
    required this.companyName,
    required this.address,
    required this.services,
    required this.serviceProviderId,
  }) : super(key: key);

  @override
  _ServiceProviderDetailsPageState createState() =>
      _ServiceProviderDetailsPageState();
}

class _ServiceProviderDetailsPageState
    extends State<ServiceProviderDetailsPage> {

  Future<Map<String, dynamic>?> fetchServiceProviderDetails() async {
    try {
      // Query Firestore for the document with the specified company name
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Service Provider')
          .where('companyName', isEqualTo: widget.companyName)
          .limit(1) // Limit to one document
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No document found with companyName: ${widget.companyName}');
        return null;
      }

      return querySnapshot.docs.first.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching service provider details: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> fetchReviews(String companyName) {
    try {
      return FirebaseFirestore.instance
          .collection('Reviews')
          .where('companyName', isEqualTo: companyName)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Provider Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchServiceProviderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching details: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('Service provider not found or no data available.'),
            );
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['companyName'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Category: ${data['category'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Service: ${data['service'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Price: ${data['price'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Email: ${data['email'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Address: ${data['address'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Reviews:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: fetchReviews(widget.companyName),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (reviewSnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading reviews: ${reviewSnapshot.error}',
                            ),
                          );
                        } else if (!reviewSnapshot.hasData ||
                            reviewSnapshot.data!.isEmpty) {
                          return Text('No reviews available.');
                        } else {
                          final reviews = reviewSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return ListTile(
                                title:
                                    Text(review['reviewerName'] ?? 'Anonymous'),
                                subtitle: Text(review['reviewText'] ?? ''),
                              );
                            },
                          );
                        }
                      },
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
