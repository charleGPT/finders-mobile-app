// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:math'; //randomize
import 'package:finders_v1_1/Service_Provider/service_provider_login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerRegistrationPage extends StatefulWidget {
  const PartnerRegistrationPage({super.key});

  @override
  _PartnerRegistrationPageState createState() =>
      _PartnerRegistrationPageState();
}

class _PartnerRegistrationPageState extends State<PartnerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(); // For nullable price
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Category dropdown value
  String? selectedCategory;

  // Category list
  List<String> categories = ['Household', 'Beauty', 'Electronics', 'Other'];

  // Function to check if the registration number exists in the CIPC collection
  Future<bool> _isRegistrationNumberValid(String registrationNumber) async {
    final QuerySnapshot result = await _firestore
        .collection('CIPC')
        .where('registrationNumber', isEqualTo: registrationNumber)
        .get();
    return result.docs.isNotEmpty; // Returns true if the number exists
  }

  // Function to check if the company name exists in the CIPC collection
  Future<bool> _isCompanyNameValid(String companyName) async {
    final QuerySnapshot result = await _firestore
        .collection('CIPC')
        .where('companyName', isEqualTo: companyName)
        .get();
    return result.docs.isNotEmpty; // Returns true if the company name exists
  }

// Function to generate a 5-digit random number as a String
  String generateServiceProviderId() {
    var random = Random();
    int randomNumber = 10000 +
        random.nextInt(90000); // Generates a number between 10000 and 99999
    return randomNumber.toString(); // Convert the integer to a String
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration number does not exist!')),
        );
        return;
      }

      // Check if the company name is valid
      bool isCompanyNameValid =
          await _isCompanyNameValid(_companyNameController.text);
      if (!isCompanyNameValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company name does not exist!')),
        );
        return;
      }

      try {
        // Register the service provider with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Generate the random serviceProviderId
        String serviceProviderId = generateServiceProviderId();

        // Save additional service provider information to Firestore
        await _firestore
            .collection('Service Provider')
            .doc(userCredential.user!.uid)
            .set({
          'companyName': _companyNameController.text,
          'registrationNumber': _registrationNumberController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'category': selectedCategory,
          'service': _serviceController.text,
          'price': _priceController.text.isEmpty
              ? null
              : double.tryParse(_priceController.text), // Nullable price
          'serviceProviderId':
              serviceProviderId, // Add the serviceProviderId here
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
        title: const Text('Service Provider Registration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Company Name
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Registration Number (13 digits)
              TextFormField(
                maxLength: 13,
                controller: _registrationNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Company Registration Number (13 digits)'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 13) {
                    return 'Please enter a valid 13-digit registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Service Name
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the services you offer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Price (nullable)
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Service Price (optional)'),
              ),
              const SizedBox(height: 10),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: registerPartner,
                child: const Text('Register'),
              ),

              // TextButton to go to login page
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, '/serviceProviderLoginPage');
                },
                child: const Text('Already Registered? Login here.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
