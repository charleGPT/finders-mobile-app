// ignore_for_file: unnecessary_null_in_if_null_operators

import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'dart:io'; // Use dart:io only for mobile platforms
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _priceController = TextEditingController();

  String? selectedCategory;
  List<String> categories = ['Household', 'Beauty', 'Electronics', 'Other'];
  String? _profilePictureUrl;
  String? _email;
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('Service Provider').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _companyNameController.text = userData['companyName'] ?? '';
            _email = userData['email'] ?? '';
            _regNumberController.text = userData['registrationNumber'] ?? '';
            _serviceController.text = userData['service'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _priceController.text =
                userData['price'] != null ? userData['price'].toString() : '';
            selectedCategory = userData['category'];
            _profilePictureUrl = userData['profilePicture'] ?? null;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String? downloadUrl;

      // Upload image if one is selected
      if (_imageFile != null) {
        try {
          downloadUrl = await _uploadProfilePicture();
          if (downloadUrl == null) {
            // Handle the case where the upload failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image upload failed')),
            );
            return; // Exit the method early if upload fails
          }
        } catch (e) {
          print("Error uploading image: $e");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
          return;
        }
      }

      try {
        await _firestore.collection('Service Provider').doc(user.uid).update({
          'companyName': _companyNameController.text.trim(),
          'address': _addressController.text.trim(),
          'category': selectedCategory,
          'service': _serviceController.text.trim(),
          'price': _priceController.text.isEmpty
              ? null
              : double.tryParse(_priceController.text.trim()),
          if (downloadUrl != null) 'profilePicture': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        _loadUserData(); // Reload user data to refresh UI
      } catch (e) {
        print("Error updating Firestore document: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadProfilePicture() async {
    User? user = _auth.currentUser;
    if (user != null && _imageFile != null) {
      String filePath = 'profilePictures/${user.uid}.jpg';
      try {
        FirebaseStorage storage = FirebaseStorage.instance;

        TaskSnapshot uploadTask;
        if (kIsWeb) {
          final byteData = await _imageFile!.readAsBytes();
          uploadTask = await storage.ref(filePath).putData(byteData);
        } else {
          uploadTask =
              await storage.ref(filePath).putFile(File(_imageFile!.path));
        }

        String downloadURL = await uploadTask.ref.getDownloadURL();
        print("Uploaded image URL: $downloadURL"); // Log the URL
        setState(() {
          _profilePictureUrl =
              '$downloadURL?timestamp=${DateTime.now().millisecondsSinceEpoch}';
        });
        return downloadURL;
      } catch (e) {
        print("Error during upload: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        return null;
      }
    }
    return null;
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
          : Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        child: _profilePictureUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _profilePictureUrl!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading image: $error");
                                    return const Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _serviceController,
                      decoration: const InputDecoration(
                        labelText: 'Service You Offer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Service Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
