import 'package:finders_v1_1/Client/screens/faqs_page.dart';
import 'package:finders_v1_1/Service_Provider/service_Appointment.dart';
import 'package:finders_v1_1/Client/screens/all_companies.dart';
import 'package:finders_v1_1/Client/screens/client_profile.dart';
import 'package:finders_v1_1/Client/screens/contact_us.dart';
import 'package:finders_v1_1/about_us.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key});

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome> {
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
    StreamBuilder<QuerySnapshot>(
      stream: getCompaniesStream(),
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
    const Center(child: ServiceProviderAppointmentPage(companyName: '')),
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
              showSearchDialog(context);
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
              leading: const Icon(Icons.info),
              title: const Text('FAQs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQsPage()),
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
            SizedBox(
              height: 350,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Account Deactivation'),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Delete user from Firestore 'Service Provider' collection
                  await _firestore
                      .collection('Service Provider')
                      .doc(user.uid)
                      .delete();
                  await user.delete();
                  // Navigate to MainPage or show confirmation
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (Route<dynamic> route) => false,
                  );
                }
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
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
                      ),
                    );
                  }).toList(),
                ),
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
          if (indexClicked == 2)
            const Center(
                child: ServiceProviderAppointmentPage(companyName: '')),
          if (indexClicked == 3) const Center(child: ContactUsPage()),
        ],
      ),
    );
  }

  Future<void> showSearchDialog(BuildContext context) async {
    // Your existing search dialog code
  }
}
