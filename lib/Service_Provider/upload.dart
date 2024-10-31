// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    try {
      // Upload image to Firebase Storage with the specified bucket
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instanceFor(bucket: 'findersmvc.appspot.com')
          .ref('services/$fileName'); // Use the specified bucket here
      await ref.putFile(_imageFile!);

      // Get download URL
      String downloadUrl = await ref.getDownloadURL();

      // Get the current user's unique document ID in the 'Service Provider' collection
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Update the existing document with the new url
      await FirebaseFirestore.instance
          .collection('Service Provider')
          .doc(userId) // Use the logged-in user's ID as the document ID
          .update({
        'url': FieldValue.arrayUnion([downloadUrl])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Service Image")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile == null
                  ? Text("No image selected")
                  : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: Text("Choose Image"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadImage,
                child: Text("Upload Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
