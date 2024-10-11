// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unnecessary_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:flutter/services.dart'; // For generating random clientId

class ClientRegistrationPage extends StatefulWidget {
  const ClientRegistrationPage({super.key});

  @override
  _ClientRegistrationPageState createState() => _ClientRegistrationPageState();
}

class _ClientRegistrationPageState extends State<ClientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnanameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Function to generate a random 5-digit clientId
  String generateClientId() {
    var random = Random();
    int clientId = 10000 + random.nextInt(90000); // Generates a 5-digit number
    return clientId.toString();
  }

  // Function to store clientId in Firestore
  Future<void> storeClientId(String userId) async {
    String clientId = generateClientId();

    try {
      await _firestore.collection('users').doc(userId).set({
        'clientId': clientId,
        'name': _nameController.text,
        'surname': _surnanameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'contacts': _phoneController.text,
        'dateJoined': DateTime.now(),
      });

      print("Client saved successfully: $clientId");
    } catch (e) {
      print("Error storing clientId: $e");
    }
  }

  // Function to handle registration
  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Validate passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      try {
        // Register the client with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Get the user ID from the registered user
        String userId = userCredential.user!.uid;

        // Generate and store clientId
        await storeClientId(userId);

        // Navigate to a login page or dashboard after successful registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/clientLoginPage');
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
        title: const Text('Client Registration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Surname
              TextFormField(
                controller: _surnanameController,
                decoration: const InputDecoration(labelText: 'Surname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
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

              // Phone
              // Phone
              TextFormField(
                maxLength: 10,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Please enter your phone number with exactly 10 digits';
                  }
                  // Optional: Check that it contains only digits
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Phone number must only contain digits';
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
                onPressed: registerUser,
                child: const Text('Register'),
              ),

              // TextButton to go to login page
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/clientLoginPage');
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
