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
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              // Replace with the actual profile picture URL
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
                            Text(serviceProvider['location']),
                            Text(serviceProvider['contact']),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow),
                            IconButton(
                              icon: const Icon(Icons.lock),
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
