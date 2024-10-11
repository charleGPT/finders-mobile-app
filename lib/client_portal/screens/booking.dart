// ignore_for_file: use_super_parameters, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/client_portal/screens/payment.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final String serviceProviderId;

  const BookingPage({Key? key, required this.serviceProviderId})
      : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String address = '';
  String companyName = '';
  List<Map<String, dynamic>> services = [];
  Map<String, double> prices = {};
  Map<String, int> serviceQuantities = {};
  double totalCost = 0.0;

  // Fetch service provider details
  Future<void> fetchServiceProviderDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Service Provider')
          .doc(widget.serviceProviderId)
          .get();

      if (doc.exists) {
        var data = doc.data();
        address = data?['address'] ?? 'No address available';
        companyName = data?['companyName'] ?? 'Unknown Company';
        services = List<Map<String, dynamic>>.from(data?['services'] ?? []);

        for (var service in services) {
          serviceQuantities[service['name']] = 0;
          prices[service['name']] = service['price'];
        }
      }
    } catch (e) {
      print('Error fetching service provider details: $e');
    }
  }

  // Calculate total cost
  void calculateTotalCost() {
    double total = 0.0;
    for (var service in services) {
      int quantity = serviceQuantities[service['name']] ?? 0;
      total += (prices[service['name']] ?? 0) * quantity;
    }
    setState(() {
      totalCost = total;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchServiceProviderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchServiceProviderDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Name: $companyName',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Address: $address',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        var service = services[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(service['name'],
                                style: const TextStyle(fontSize: 16)),
                            Text('R${service['price']}',
                                style: const TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (serviceQuantities[service['name']]! >
                                          0) {
                                        serviceQuantities[service['name']] =
                                            serviceQuantities[
                                                    service['name']]! -
                                                1;
                                        calculateTotalCost();
                                      }
                                    });
                                  },
                                ),
                                Text(serviceQuantities[service['name']]
                                    .toString()),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      serviceQuantities[service['name']] =
                                          serviceQuantities[service['name']]! +
                                              1;
                                      calculateTotalCost();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('R$totalCost',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Gather selected services and their quantities
                          List<String> selectedServices = [];
                          for (var service in services) {
                            int quantity =
                                serviceQuantities[service['name']] ?? 0;
                            if (quantity > 0) {
                              selectedServices
                                  .add('${service['name']} (x$quantity)');
                            }
                          }

                          // Navigate to PaymentPage with booking details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                companyName: companyName,
                                services: selectedServices,
                                totalPrice: totalCost,
                                price: 0.0,
                                service:
                                    '', // Make sure this is the only parameters
                              ),
                            ),
                          );
                        },
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
