// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/Service_Provider/CIPC_Reg.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PartnerRegistrationPage extends StatefulWidget {
  const PartnerRegistrationPage({Key? key}) : super(key: key);

  @override
  _PartnerRegistrationPageState createState() =>
      _PartnerRegistrationPageState();
}

class _PartnerRegistrationPageState extends State<PartnerRegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedCategory = 'Select Category';

  // Function to validate the registration number
  Future<bool> _isRegistrationNumberValid(String regNumber) async {
    // Query Firestore for documents with the specified registration number
    final query = await _firestore
        .collection('CIPC')
        .where('registrationNumber', isEqualTo: regNumber)
        .get();

    // Check if any documents were found
    return query.docs.isNotEmpty;
  }

  // Function to handle registration
  Future<void> registerPartner() async {
    if (_formKey.currentState!.validate()) {
      // Validate passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      // Check if the registration number is valid
      bool isRegNumValid =
          await _isRegistrationNumberValid(_registrationNumberController.text);
      if (!isRegNumValid) {
        // Show dialog if registration number is invalid
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Not Registered with CIPC'),
            content: const Text(
                'You are not registered with CIPC. You need to register first before using our App.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to CIPCRegistrationPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CIPCRegistrationPage()),
                  );
                },
                child: const Text('Go to CIPC'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(), // Close the dialog
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        return;
      } else {}

      try {
        // Register the service provider with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save additional service provider information to Firestore
        await _firestore
            .collection('Service Provider')
            .doc(userCredential.user!.uid)
            .set({
          'companyName': _companyNameController.text.trim(),
          'registrationNumber': _registrationNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'email': _emailController.text.trim(),
          'category': selectedCategory,
          'service': _serviceController.text.trim(),
          'price': _priceController.text.isEmpty
              ? 0.0
              : double.tryParse(_priceController.text.trim()), // Nullable price
          'dateJoined': DateTime.now(),
        });

        // Navigate to the login page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ServiceProviderLoginPage()),
        );
      } catch (e) {
        // Handle Firebase registration error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Partner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _registrationNumberController,
                decoration:
                    const InputDecoration(labelText: 'Registration Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: <String>[
                  'Select Category',
                  'IT',
                  'Consulting',
                  'Beauty',
                  'Education',
                  'HouseHold',
                  'Other'
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == 'Select Category') {
                    return 'Please select a category';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(labelText: 'Service'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: 'Price (Optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerPartner,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
