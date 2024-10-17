import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to create a new appointment
  Future<void> createAppointment({
    required String address,
    required String companyName,
    required DateTime date,
    required int price,
    required String service,
    required String serviceProviderId,
    required String userName,
  }) async {
    try {
      // Add the new appointment to the 'appointments' collection
      await _db.collection('appointments').add({
        'address': address,
        'companyName': companyName,
        'date': date,
        'price': price,
        'service': service,
        'serviceProviderId': serviceProviderId,
        'userName': userName,
        'status': 'pending', // Default status for new appointments
      });
    } catch (e) {
      print('Error creating appointment: $e');
    }
  }
}
