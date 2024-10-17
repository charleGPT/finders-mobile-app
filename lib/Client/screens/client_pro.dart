// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProPicPage extends StatefulWidget {
  const ProPicPage({super.key});

  @override
  _ProPicPageState createState() => _ProPicPageState();
}

class _ProPicPageState extends State<ProPicPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _profilePictureUrl;
  bool _isLoading = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch the user's profile picture from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _profilePictureUrl = userDoc['profilePicture'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndSaveImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Upload the image to Firebase Storage
        String fileName = 'profile_pictures/${user.uid}.jpg';
        UploadTask uploadTask =
            _storage.ref().child(fileName).putFile(_imageFile!);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update the user's profile picture URL in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'profilePicture': downloadUrl,
        });

        setState(() {
          _profilePictureUrl = downloadUrl;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Picture'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the current or selected profile picture
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : const AssetImage('assets/default_profile.png')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 20),

                  // Button to pick a new image
                  IconButton(
                    icon: const Icon(Icons.photo_camera),
                    iconSize: 30,
                    onPressed: _pickImage,
                    tooltip: 'Select new profile picture',
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: _uploadAndSaveImage,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
