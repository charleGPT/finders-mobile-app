// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String companyName;
  final List<String> services;
  final double totalPrice;

  const PaymentPage({
    super.key,
    required this.companyName,
    required this.services,
    required this.totalPrice,
    required double price,
    required String service,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  late String _cardHolderName, _bankAccountNumber, _bankCardNumber, _cvv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${widget.companyName}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text('Booked Services:', style: const TextStyle(fontSize: 18)),
              for (var service in widget.services)
                Text(service, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Total Price: R${widget.totalPrice}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Card Holder Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
                onSaved: (value) => _cardHolderName = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Bank Account Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter bank account number';
                  }
                  return null;
                },
                onSaved: (value) => _bankAccountNumber = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Bank Card Number'),
                validator: (value) {
                  if (value!.isEmpty || value.length != 16) {
                    return 'Please enter valid bank card number';
                  }
                  return null;
                },
                onSaved: (value) => _bankCardNumber = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CVV'),
                validator: (value) {
                  if (value!.isEmpty || value.length != 3) {
                    return 'Please enter valid CVV';
                  }
                  return null;
                },
                onSaved: (value) => _cvv = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Add booking details to 'appointments' collection
                    FirebaseFirestore.instance.collection('appointments').add({
                      'companyName': widget.companyName,
                      'services': widget.services,
                      'totalPrice': widget.totalPrice,
                      'clientName': _cardHolderName,
                      'date': DateTime.now(),
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
