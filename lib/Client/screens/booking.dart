import 'package:finders_v1_1/Client/screens/payment.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final String companyName;
  final String address;
  final List<String> services;
  final List<double> prices;
  final String providerId;
  final String serviceProviderId;
  final List<int> quantities;

  const BookingPage({
    super.key,
    required this.companyName,
    required this.address,
    required this.services,
    required this.prices,
    required this.providerId,
    required this.serviceProviderId,
    required this.quantities,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<int> quantities = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    quantities = List.filled(widget.services.length, 0);
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
            // Title
            Center(
              child: Text(
                widget.companyName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(
                child: Text(widget.address,
                    style: TextStyle(fontSize: 16, color: Colors.grey))),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(183, 245, 218, 159),
                  borderRadius: BorderRadius.circular(4.0),
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
                    return Row(
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
                  onPressed: () {
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
                          // providerId: widget.providerId, service: [],
                          //serviceProviderDocId: '',
                          //services: [],
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Proceed to Payment')),
                    );
                  },
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
