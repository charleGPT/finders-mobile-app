// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:finders_v1_1/Service_Provider/banking_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceProfilePage extends StatefulWidget {
  const ServiceProfilePage({super.key});

  @override
  _ServiceProfilePageState createState() => _ServiceProfilePageState();
}

class _ServiceProfilePageState extends State<ServiceProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(); // Price controller

  // Category dropdown value
  String? selectedCategory;

  // Category list
  List<String> categories = ['Household', 'Beauty', 'Electronics', 'Other'];
  String? _profilePictureUrl;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch the user data from Firestore
      DocumentSnapshot userData =
          await _firestore.collection('Service Provider').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _companyNameController.text = userData['companyName'];
          _email = userData['email'];
          _regNumberController.text = userData['registrationNumber'];
          _serviceController.text = userData['service'];
          _addressController.text = userData['address'];
          _priceController.text = userData['price'] != null
              ? userData['price'].toString()
              : ''; // Load price
          selectedCategory = userData['category'];

          _isLoading = false;
        });
      }
    }
  }

  // Update user profile
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update the user data in Firestore
      await _firestore.collection('Service Provider').doc(user.uid).update({
        'companyName': _companyNameController.text.trim(),
        'address': _addressController.text.trim(),
        'category': selectedCategory,
        'service': _serviceController.text.trim(),
        'price': _priceController.text.isEmpty
            ? null
            : double.tryParse(_priceController.text.trim()), // Update price
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profilePictureUrl != null
                          ? NetworkImage(_profilePictureUrl!)
                          : const AssetImage('/assets/default_profile.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 20),

                    // Company Name field (read-only)
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),

                    // Registration Number field (read-only)
                    TextField(
                      controller: _regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Email (read-only)
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Address field
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

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
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Service field
                    TextField(
                      controller: _serviceController,
                      decoration: const InputDecoration(
                        labelText: 'Service You Offer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price field (editable)
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Service Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BANKING DETAILS',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    BankingDetailsForm(),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      onPressed: _updateUserData,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
