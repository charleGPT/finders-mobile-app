import 'package:finders_v1_1/Client/screens/payment.dart';
import 'package:finders_v1_1/Service_Provider/upload.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatefulWidget {
  final String companyName;
  final String address;
  final List<String> services;
  final List<double> prices;
  final String providerId;
  final String serviceProviderId;

  const BookingPage({
    super.key,
    required this.companyName,
    required this.address,
    required this.services,
    required this.prices,
    required this.providerId,
    required this.serviceProviderId,
    required List quantities,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<int> quantities = [];
  double totalPrice = 0;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    quantities = List.filled(widget.services.length, 0);
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

  void calculateTotalPrice() {
    double total = 0;
    for (int i = 0; i < widget.prices.length; i++) {
      total += quantities[i] * widget.prices[i];
    }
    setState(() {
      totalPrice = total;
    });
  }

  bool get isAnyQuantityGreaterThanZero {
    return quantities.any((quantity) => quantity > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.companyName} Services'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    widget.companyName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.address,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            imageUrls.isEmpty
                ? Column(
                    children: [
                      Text("No images available."),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadPage(),
                            ),
                          );
                        },
                        child: Text("Upload Image"),
                      ),
                    ],
                  )
                : Container(
                    height: 300,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(183, 245, 218, 159),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: widget.services.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.services[index],
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'R${widget.prices[index].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: Colors.black),
                                onPressed: () {
                                  if (quantities[index] > 0) {
                                    setState(() {
                                      quantities[index]--;
                                      calculateTotalPrice();
                                    });
                                  }
                                },
                              ),
                              Text(
                                quantities[index].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    quantities[index]++;
                                    calculateTotalPrice();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL: R${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: isAnyQuantityGreaterThanZero
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                companyName: widget.companyName,
                                address: widget.address,
                                services: widget.services,
                                prices: widget.prices,
                                totalPrice: totalPrice,
                                serviceProviderId: widget.serviceProviderId,
                                quantities: quantities,
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Proceed to Payment')),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[300],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: Text('Book Now', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
