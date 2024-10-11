// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api, unnecessary_null_in_if_null_operators

import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'dart:io'; // Use dart:io only for mobile platforms
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactsController = TextEditingController();

  String? _profilePictureUrl;
  String? _email;
  bool _isLoading = true;

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
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        print(userData.data()); // Log the document data for debugging
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _surnameController.text = userData['surname'] ?? '';
          _email = userData['email'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _contactsController.text = userData['contacts'] ?? '';
          _profilePictureUrl = userData['profilePicture'] ?? null;
          _isLoading = false;
        });
      }
    }
  }

  // Function to update user profile
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'address': _addressController.text.trim(),
        'contacts': _contactsController.text.trim(),
        'profilePicture': _profilePictureUrl,
      });

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

          await _firestore.collection('users').doc(user.uid).update({
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

          await _firestore.collection('users').doc(user.uid).update({
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

                    // Name field
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Surname field
                    TextField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Surname',
                        border: OutlineInputBorder(),
                      ),
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

                    // Contacts field
                    TextField(
                      controller: _contactsController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
