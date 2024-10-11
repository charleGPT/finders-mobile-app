// ignore_for_file: use_build_context_synchronously

import 'package:finders_v1_1/about_us.dart';
import 'package:finders_v1_1/Client/all_companies.dart';
import 'package:finders_v1_1/Client/appointment_page.dart';
import 'package:finders_v1_1/Client/booking.dart';
import 'package:finders_v1_1/Client/client_profile.dart';
import 'package:finders_v1_1/Client/contact_us.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var indexClicked = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> categories = ['Household', 'Beauty', 'Electronics', 'Other'];
  String? selectedCategory;

  // Function to filter companies by category
  Stream<QuerySnapshot> getCompaniesStream() {
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      return _firestore
          .collection('Service Provider')
          .where('category', isEqualTo: selectedCategory)
          .snapshots();
    } else {
      return _firestore.collection('Service Provider').snapshots();
    }
  }

  late final List<Widget> screens = [
    const Center(child: AllCompaniesPage()),
    const Center(child: AppointmentPage()),
    const Center(child: ContactUsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('FINDERS'),
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images-platform.99static.com//yHXhWx8e6BhBhnNcQAFbEnZnaiI=/341x74:915x648/fit-in/500x500/99designs-contests-attachments/116/116036/attachment_116036922',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String searchQuery = '';
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Search Service Providers'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter company name or service',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 50),
                            searchQuery.isNotEmpty
                                ? StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Service Provider')
                                        .where('companyName',
                                            isGreaterThanOrEqualTo: searchQuery)
                                        .where('service',
                                            isLessThanOrEqualTo:
                                                '$searchQuery\uf8ff')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      var results = snapshot.data!.docs;

                                      if (results.isEmpty) {
                                        return const Text('No results found');
                                      }

                                      return SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: results.length,
                                          itemBuilder: (context, index) {
                                            var data = results[index].data()
                                                as Map<String, dynamic>;
                                            return ListTile(
                                              title: Text(data['companyName']),
                                              subtitle: Text(data['service']),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Conditionally display the row of category buttons only for index 0
          if (indexClicked == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0), // Add spacing between buttons
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCategory == category
                              ? Colors.blueAccent
                              : Colors.grey, // Highlight selected category
                        ),
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          // Display service providers based on the selected category
          if (indexClicked == 0)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getCompaniesStream(), // Filtered by selectedCategory
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final serviceProviders = snapshot.data!.docs;

                  if (serviceProviders.isEmpty) {
                    return const Center(
                        child: Text('No Service Providers available.'));
                  }

                  return ListView.builder(
                    itemCount: serviceProviders.length,
                    itemBuilder: (context, index) {
                      var serviceProvider = serviceProviders[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOuxrvcNMfGLh73uKP1QqYpKoCB0JLXiBMvA&s',
                            ),
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
                              String providerId = serviceProvider
                                  .id; // Get the providerId (document ID)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    providerId: providerId,
                                    companyName: '',
                                    address: '',
                                    services: [],
                                    prices: [],
                                  ),
                                ),
                              );
                            },
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
        backgroundColor: Colors.blue, // Set the background color to blue
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Companies'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail), label: 'Contact Us'),
        ],
        currentIndex: indexClicked,
        selectedItemColor: Colors.white, // Color for the selected item
        unselectedItemColor: Colors.black, // Color for unselected items
        onTap: (index) {
          setState(() {
            indexClicked = index;
            selectedCategory =
                null; // Reset category selection when changing tabs
          });
        },
        fixedColor: Colors.blueAccent,
      ),
    );
  }
}
