// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api, unnecessary_null_in_if_null_operators

import 'package:finders_v1_1/Service_Provider/upload.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'dart:io'; // Use dart:io only for mobile platforms
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceProfilePage extends StatefulWidget {
  const ServiceProfilePage(
      {super.key,
      required String serviceProviderId,
      required String companyName});

  @override
  _ServiceProfilePageState createState() => _ServiceProfilePageState();
}

class _ServiceProfilePageState extends State<ServiceProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  String selectedCategory = 'Select Category';
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  String? _profilePictureUrl;
  String? _email;
  bool _isLoading = true;
  String? _selectedBank;

  final List<String> _bankNames = [
    'Capitec Pay',
    'FNB',
    'Absa',
    'Standard Bank',
    'NedBank',
  ];

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // Use XFile for platform compatibility

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
          print(userData.data()); // Log the document data for debugging
          setState(() {
            _companyNameController.text = userData['companyName'] ?? '';
            _registrationNumberController.text =
                userData['registrationNumber'] ?? '';
            _email = userData['email'] ?? '';
            _addressController.text = userData['address'] ?? '';
            selectedCategory = userData['category'] ?? '';
            _profilePictureUrl = userData['profilePicture'] ?? null;
            print("Profile Picture URL: $_profilePictureUrl");
            _serviceController.text = userData['service'] ?? '';
            _priceController.text = (userData['price'] != null)
                ? userData['price']
                    .toString() // Ensure it's converted to string if it's a number
                : '';
            _accountHolderController.text = userData['price'] ?? '';
            _accountNumberController.text = userData['price'] ?? '';
            _branchCodeController.text = userData['price'] ?? '';
            // Debug print
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false; // Stop loading if no data
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user data found.')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        print("Error loading user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading if user is null
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
    }
  }

  // Function to update user profile
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final updateData = {
        'companyName': _companyNameController.text.trim(),
        'registrationNumber': _registrationNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'service': _serviceController.text.trim(),
        'category': selectedCategory,
        'price': _priceController.text.isEmpty
            ? 0.0
            : int.tryParse(_priceController.text.trim()),
        'BankName': _selectedBank,
        'accountHolder': _accountHolderController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'branchCode': _branchCodeController.text.trim(),
      };

      // Set a default profile picture URL if none is provided
      updateData['profilePicture'] = _profilePictureUrl ??
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.vecteezy.com%2Ffree-vector%2Fdefault-profile-picture&psig=AOvVaw3iEo7_pOokW02jmV7r5XSy&ust=1730387084366000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCNiOxa6wtokDFQAAAAAdAAAAABAJ';

      await _firestore
          .collection('Service Provider')
          .doc(user.uid)
          .update(updateData);

      if (!mounted) return; // Check if widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      await _uploadProfilePicture();
    }
  }

  // Function to upload image to Firebase Storage and get the URL
  Future<void> _uploadProfilePicture() async {
    User? user = _auth.currentUser;
    if (user != null && _imageFile != null) {
      String filePath = 'images/${user.uid}.png';
      try {
        FirebaseStorage storage =
            FirebaseStorage.instanceFor(bucket: 'findersmvc.appspot.com');

        print("Uploading image to $filePath");

        if (kIsWeb) {
          final byteData = await _imageFile!.readAsBytes();
          TaskSnapshot uploadTask =
              await storage.ref(filePath).putData(byteData);
          print("Upload complete");

          String downloadURL = await uploadTask.ref.getDownloadURL();
          print("Download URL: $downloadURL");

          setState(() {
            _profilePictureUrl = downloadURL;
          });

          await _firestore.collection('Service Provider').doc(user.uid).update({
            'profilePicture': _profilePictureUrl,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully')),
          );
        } else {
          TaskSnapshot uploadTask =
              await storage.ref(filePath).putFile(File(_imageFile!.path));
          print("Upload complete");

          String downloadURL = await uploadTask.ref.getDownloadURL();
          print("Download URL: $downloadURL");

          setState(() {
            _profilePictureUrl = downloadURL;
          });

          await _firestore.collection('Service Provider').doc(user.uid).update({
            'profilePicture': _profilePictureUrl,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully')),
          );
        }
      } catch (e) {
        print("Error during upload: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
          : Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Pick image on tap
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : const AssetImage('lib/assets/default_profile.png')
                                as ImageProvider,
                        onBackgroundImageError: (_, __) {
                          setState(() {
                            _profilePictureUrl =
                                null; // Set to null if there's an error
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Add more Service Images",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Name field
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'company Name',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Surname field
                    TextField(
                      controller: _registrationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Email (non-editable)
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

                    // // Contacts field
                    // TextField(
                    //   controller: _categoryController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'category',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'price',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bank Name Dropdown
                    // DropdownButtonFormField<String>(
                    //   value: _selectedBank,
                    //   hint: const Text('Select Bank'),
                    //   items: _bankNames.map((String bank) {
                    //     return DropdownMenuItem<String>(
                    //       value: bank,
                    //       child: Text(bank),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _selectedBank = newValue;
                    //     });
                    //   },
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // // Contacts field
                    // TextField(
                    //   controller: _accountHolderController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Account Holder Name',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // // Contacts field
                    // TextField(
                    //   controller: _accountNumberController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Account Number',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // // Contacts field
                    // TextField(
                    //   controller: _branchCodeController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Branch Code',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

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
