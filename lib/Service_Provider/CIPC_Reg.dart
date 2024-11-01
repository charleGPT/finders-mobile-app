import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_reg.dart';
import 'package:flutter/material.dart';

class CIPCRegistrationPage extends StatefulWidget {
  const CIPCRegistrationPage({super.key});

  @override
  _CIPCRegistrationPageState createState() => _CIPCRegistrationPageState();
}

class _CIPCRegistrationPageState extends State<CIPCRegistrationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Function to handle registration and store directly in Firestore
  Future<void> registerPartner() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save user information to Firestore
        await _firestore.collection('CIPC').add({
          'companyName': _companyNameController.text.trim(),
          'registrationNumber': _registrationNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'email': _emailController.text.trim(),
          'dateJoined': DateTime.now(),
        });

        // Navigate to the next registration page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PartnerRegistrationPage()),
        );
      } catch (e) {
        // Handle Firestore storage error
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
        title: const Text('CIPC Registration'),
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
                decoration: const InputDecoration(labelText: 'Registration Number'),
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
