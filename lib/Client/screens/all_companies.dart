import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AllCompaniesPage extends StatelessWidget {
  const AllCompaniesPage({super.key});

  // Fetch service providers from Firestore
  Stream<QuerySnapshot> getServiceProviders() {
    return FirebaseFirestore.instance
        .collection('Service Provider')
        .snapshots();
  }

  // Update the rating for the service provider
  Future<void> updateRating(String serviceProviderId, double newRating) async {
    DocumentReference serviceProviderRef = FirebaseFirestore.instance
        .collection('Service Provider')
        .doc(serviceProviderId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(serviceProviderRef);
      if (!snapshot.exists) {
        throw Exception("Service provider does not exist!");
      }

      double currentRating = snapshot.get('rating') ?? 2.5;
      int ratingCount = snapshot.get('ratingCount') ?? 0;

      // Calculate the new average rating
      double updatedRating =
          ((currentRating * ratingCount) + newRating) / (ratingCount + 1);
      int updatedRatingCount = ratingCount + 1;

      // Update Firestore with the new rating
      transaction.update(serviceProviderRef, {
        'rating': updatedRating,
        'ratingCount': updatedRatingCount,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              //  actual profile picture URL
              backgroundImage: NetworkImage(
                  'https://images-platform.99static.com//yHXhWx8e6BhBhnNcQAFbEnZnaiI=/341x74:915x648/fit-in/500x500/99designs-contests-attachments/116/116036/attachment_116036922'),
            ),
            const Text('FiNDERS'),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Handle menu action
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[100],
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Category or Keyword',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getServiceProviders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final serviceProviders = snapshot.data!.docs;

                if (serviceProviders.isEmpty) {
                  return const Center(
                      child: Text('No service providers found.'));
                }

                return ListView.builder(
                  itemCount: serviceProviders.length,
                  itemBuilder: (context, index) {
                    var serviceProvider = serviceProviders[index];
                    double rating = serviceProvider['rating'] ?? 2.5;
                    int ratingCount = serviceProvider['ratingCount'] ?? 0;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          // Replace with actual profile picture URL
                          backgroundImage: NetworkImage(
                              'https://images-platform.99static.com//yHXhWx8e6BhBhnNcQAFbEnZnaiI=/341x74:915x648/fit-in/500x500/99designs-contests-attachments/116/116036/attachment_116036922'),
                        ),
                        title: Text(serviceProvider['companyName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(serviceProvider['service']),
                            Text('Price: ${serviceProvider['price']}'),
                            Text(serviceProvider['address']),
                            Text(serviceProvider['contact']),
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (newRating) {
                                    // Update rating in Firestore
                                    updateRating(serviceProvider.id, newRating);
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text('($ratingCount)')
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_bag),
                              onPressed: () {
                                // Handle book now action
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: '',
          ),
        ],
      ),
    );
  }
}
