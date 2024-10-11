// ignore_for_file: use_build_context_synchronously

import 'package:finders_v1_1/client_portal/screens/about_us.dart';
import 'package:finders_v1_1/client_portal/screens/all_companies.dart';
import 'package:finders_v1_1/client_portal/screens/appointment_page.dart';
import 'package:finders_v1_1/client_portal/screens/client_profile.dart';
import 'package:finders_v1_1/client_portal/screens/contact_us.dart';
import 'package:finders_v1_1/defaults/defaults.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@override
State<ClientHomePage> createState() => _ClientHomePageState();

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

  // Fetch service providers from Firestore
  Stream<QuerySnapshot> getServiceProviders() {
    return _firestore.collection('Service Provider').snapshots();
  }

  late final List<Widget> screens =
      // Your existing StreamBuilder and other widgets...
      [
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
                leading: const CircleAvatar(
                    //backgroundImage: NetworkImage(
                    // serviceProvider['profilePictureUrl'] ??
                    //    'https://via.placeholder.com/150'),
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
                    // Navigate to a detailed company page if needed
                    Navigator.pushNamed(context, '/bookingPage');
                  },
                ),
              ),
            );
          },
        );
      },
    ),
    const Center(
      child: AllCompaniesPage(),
    ),
    const Center(
      child: AppointmentPage(),
    ),
    const Center(
      child: ContactUsPage(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
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
                'https://www.example.com/path_to_user_profile_picture.jpg',
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
                            const SizedBox(
                                height:
                                    10), // Added space between TextField and results
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
                                        height: 200, // Adjust height as needed
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
          // Conditionally display the row of category buttons only for index 0 and 1
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
                          : Colors.grey, // Highlight selected category
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
          // Display service providers based on the selected category when indexClicked is 0 or 1
          if (indexClicked == 0 || indexClicked == 1)
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
                        child: ListTile(
                          leading: const CircleAvatar(
                              //backgroundImage: NetworkImage(
                              // serviceProvider['profilePictureUrl'] ??
                              //    'https://via.placeholder.com/150'),
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
                              // Pass the service provider ID to the BookingPage
                              Navigator.pushNamed(
                                context,
                                '/bookingPage',
                                arguments: serviceProvider.id, // Pass the ID
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
          // Display other screens if not index 0 or 1
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
