// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/client_portal/screens/about_us.dart';
import 'package:finders_v1_1/client_portal/screens/all_companies.dart';
import 'package:finders_v1_1/client_portal/screens/appointment_page.dart';
import 'package:finders_v1_1/client_portal/screens/contact_us.dart';
import 'package:finders_v1_1/defaults/defaults.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:finders_v1_1/service_provider_portal/pages/provider_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key});

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Added GlobalKey
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

  // Fetch service providers from Firestore
  Stream<QuerySnapshot> getServiceProviders() {
    return _firestore.collection('Service Provider').snapshots();
  }

  late final List<Widget> screens = [
    StreamBuilder<QuerySnapshot>(
      stream: getServiceProviders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final serviceProviders = snapshot.data!.docs;

        if (serviceProviders.isEmpty) {
          return const Center(child: Text('No Service Providers available.'));
        }

        return ListView.builder(
          itemCount: serviceProviders.length,
          itemBuilder: (context, index) {
            var serviceProvider = serviceProviders[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const CircleAvatar(),
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
                    Navigator.pushNamed(context, '/bookingPage');
                  },
                ),
              ),
            );
          },
        );
      },
    ),
    const Center(child: AllCompaniesPage()),
    const Center(child: AppointmentPage()),
    const Center(child: ContactUsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        title: const Text('FINDERS'),
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ServiceProfilePage()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://www.example.com/path_to_user_profile_picture.jpg',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Open the drawer using the GlobalKey
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
          if (indexClicked == 0 || indexClicked == 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: categories.map((category) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == category
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Text(category),
                  );
                }).toList(),
              ),
            ),
          if (indexClicked == 0 || indexClicked == 1)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getCompaniesStream(),
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
                        child: ListTile(
                          leading: const CircleAvatar(),
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
                              Navigator.pushNamed(context, '/bookingPage');
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (indexClicked != 0 && indexClicked != 1)
            Expanded(child: screens[indexClicked]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        type: BottomNavigationBarType.shifting,
        elevation: 60,
        selectedItemColor: Defaults.bottomNavItemSelectedColor,
        unselectedItemColor: Defaults.bottomNavItemColor,
        currentIndex: indexClicked,
        onTap: (value) {
          setState(() {
            indexClicked = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.blueAccent,
            icon: Icon(Defaults.bottomNavItemIcon[0]),
            label: Defaults.bottomNavItemText[0],
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blueAccent,
            icon: Icon(Defaults.bottomNavItemIcon[1]),
            label: Defaults.bottomNavItemText[1],
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blueAccent,
            icon: Icon(Defaults.bottomNavItemIcon[2]),
            label: Defaults.bottomNavItemText[2],
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blueAccent,
            icon: Icon(Defaults.bottomNavItemIcon[3]),
            label: Defaults.bottomNavItemText[3],
          ),
        ],
      ),
    );
  }
}
