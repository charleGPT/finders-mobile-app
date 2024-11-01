// ignore_for_file: use_build_context_synchronously

import 'package:finders_v1_1/Client/screens/appointment_page.dart';
import 'package:finders_v1_1/Client/screens/client_profile.dart';
import 'package:finders_v1_1/Client/screens/faqs_page.dart';
import 'package:finders_v1_1/Reviews/reviewsPage.dart';

import 'package:finders_v1_1/about_us.dart';
import 'package:finders_v1_1/Client/screens/all_companies.dart';
//import 'package:finders_v1_1/Client/appointment_page.dart';
import 'package:finders_v1_1/Client/screens/booking.dart';
import 'package:finders_v1_1/Client/screens/contact_us.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ClientHomePage extends StatefulWidget {
  final String companyName;
  final String address;
  final List<String> services;
  //final List<double> prices;
  final String providerId;
  final String serviceProviderId;
  final String clientId;

  const ClientHomePage({
    super.key,
    required this.companyName,
    required this.providerId,
    required this.serviceProviderId,
    required this.address,
    required this.services,
    required this.clientId,

    // required this.prices}
  });

  Future<String> fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['username']; // Adjust the field name if necessary
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return "Unknown User"; // Return a default value if the fetch fails
  }

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var indexClicked = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> imageUrls = [];
  List<String> categories = [
    'IT',
    'Consulting',
    'Beauty',
    'Education',
    'HouseHold',
    'Other'
  ];
  String? selectedCategory;
  String? companyName;
  String? address;

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

  @override
  void initState() {
    super.initState();

    fetchImages();
  }

  void fetchImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Service Provider')
          .where('companyName', isEqualTo: widget.companyName)
          .get();

      List<String> urls = [];
      for (var doc in snapshot.docs) {
        List<dynamic> urlsFromDoc = doc['url'] as List<dynamic>? ?? [];
        urls.addAll(urlsFromDoc.map((url) => url.toString()).toList());
      }

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print("Failed to fetch images: $e");
    }
  }

//back fill the missing fields
  // Future<void> backfillServiceProviderFields() async {
  //   final serviceProviders =
  //       await _firestore.collection('Service Provider').get();

  //   for (var doc in serviceProviders.docs) {
  //     final data = doc.data();
  //     if (data['totalRating'] == null || data['ratingCount'] == null) {
  //       await _firestore.collection('Service Provider').doc(doc.id).update({
  //         'totalRating': data['totalRating'] ?? 0,
  //         'ratingCount': data['ratingCount'] ?? 0,
  //       });
  //       print("Backfilled fields for provider ID: ${doc.id}");
  //     }
  //   }
  // }

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
                    // zText('Email: ${serviceProvider['email']}'),
                    imageUrls.isEmpty
                        ? Column(
                            children: [
                              Text("No images available."),
                              SizedBox(height: 10),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => UploadPage(),
                              //       ),
                              //     );
                              //   },
                              //   child: Text("Upload Image"),
                              // ),
                            ],
                          )
                        : Container(
                            height: 300,
                            padding: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                            ),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),

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
    // const Center(
    //  child: ServiceProviderAppointmentPage(
    // companyName: '',

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
              MaterialPageRoute(builder: (context) => ProfilePage()),
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
              leading: const Icon(Icons.question_answer),
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
              title: const Text('Deactivate Account'),
              onTap: () async {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Prevents dismissal by tapping outside
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Deactivation'),
                      content: const Text(
                          'Are you sure you want to deactivate your account? This action cannot be undone.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('Confirm'),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              // Delete user from Firestore 'users' collection
                              await FirebaseFirestore.instance
                                  .collection('Service Provider')
                                  .doc(user.uid)
                                  .delete();
                              await user
                                  .delete(); // Deletes the Firebase Auth user

                              // Navigate to MainPage
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainPage()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/search-concept-landing-page_52683-11001.jpg?t=st=1730398796~exp=1730402396~hmac=7e775ea41c31adf97c1027cde5c7c53953cd63088957b2de0a419f0457139d02&w=996', // Replace with your image URL
            fit: BoxFit.cover, // Cover the entire screen
          ),
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
                          leading: GestureDetector(
                            onTap: () {
                              String clientId = '';
                              String serviceProviderId = '';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReviewPage(
                                            clientId: clientId,
                                            serviceProviderId:
                                                serviceProviderId,
                                            username: '',
                                          )));
                            },
                            child: const CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOuxrvcNMfGLh73uKP1QqYpKoCB0JLXiBMvA&s',
                              ),
                            ),
                          ),
                          title: Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text(serviceProvider['companyName']),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: RatingBar.builder(
                                      itemSize: 15,
                                      initialRating: (serviceProvider.data()
                                                      as Map<String, dynamic>)
                                                  .containsKey('ratingCount') &&
                                              (serviceProvider.data() as Map<
                                                      String,
                                                      dynamic>)['ratingCount'] >
                                                  0
                                          ? ((serviceProvider.data()
                                                          as Map<String, dynamic>)[
                                                      'totalRating'] ??
                                                  0) /
                                              ((serviceProvider.data()
                                                      as Map<String, dynamic>)['ratingCount'] ??
                                                  1)
                                          : 0, // Default to 0 if fields are missing or rating count is 0
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: EdgeInsets.zero,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) async {
                                        final serviceProviderId =
                                            serviceProvider.id;

                                        // Update totalRating and ratingCount atomically in Firestore
                                        await _firestore
                                            .collection('Service Provider')
                                            .doc(serviceProviderId)
                                            .update({
                                          'totalRating': FieldValue.increment(
                                              rating), // Increment total rating
                                          'ratingCount': FieldValue.increment(
                                              1), // Increment rating count
                                        });

                                        print(
                                            "Updated rating to: $rating for provider ID: $serviceProviderId");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Service: ${serviceProvider['service']}'),
                              //  Text('Email: ${serviceProvider['email']}'),
                              imageUrls.isEmpty
                                  ? Column(
                                      children: [
                                        Text("No images available."),
                                        // SizedBox(height: 10),
                                      ],
                                    )
                                  : Container(
                                      height: 100,
                                      padding: EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 2),
                                      ),
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 4,
                                          crossAxisSpacing: 4,
                                        ),
                                        itemCount: 1,
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              imageUrls[index],
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              Text('Address: ${serviceProvider['address']}'),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () {
                                  // Navigate to the BookingPage with service provider details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingPage(
                                        companyName:
                                            serviceProvider['companyName'],
                                        address: serviceProvider['address'],
                                        // Change this part to check if 'services' is a String or List
                                        services:
                                            serviceProvider['service'] is List
                                                ? List<String>.from(
                                                    serviceProvider['service'])
                                                : [serviceProvider['service']],
                                        // Adjust this part similarly for 'prices'
                                        prices: serviceProvider['price'] is List
                                            ? List<double>.from(
                                                serviceProvider['price'].map(
                                                    (price) => price is int
                                                        ? price.toDouble()
                                                        : price))
                                            : [
                                                serviceProvider['price'] is int
                                                    ? serviceProvider['price']
                                                        .toDouble()
                                                    : serviceProvider['price']
                                              ],
                                        serviceProviderId: serviceProvider[
                                            'serviceProviderId'],
                                        providerId: serviceProvider[
                                            'serviceProviderId'],
                                        quantities: [],
                                      ),
                                    ),
                                  );
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
          if (indexClicked != 0 && indexClicked != 1)
            Expanded(child: screens[indexClicked]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            indexClicked = index;
            selectedCategory = null;
          });
        },
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
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
                                  isLessThanOrEqualTo: '$searchQuery\uf8ff')
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
  }
}
