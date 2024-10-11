// import 'package:firebase_database/firebase_database.dart';

// class DatabaseService {
//   final DatabaseReference _database = FirebaseDatabase.instance.reference();

//   // Write Data
//   Future<void> writeUserData(String userId, Map<String, dynamic> userData) async {
//     await _database.child('users/$userId').set(userData);
//   }

//   // Read Data
//   Future<DataSnapshot> getUserData(String userId) async {
//     return await _database.child('users/$userId').once();
//   }
// }
