import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String clientId;
  final String serviceProviderId;
  final String reviewText;
  final int rating;
  final DateTime timestamp;
  final String username; // Add the username field

  ReviewModel({
    required this.clientId,
    required this.serviceProviderId,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
    required this.username, // Include in the constructor
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      clientId: json['clientId'],
      serviceProviderId: json['serviceProviderId'],
      reviewText: json['reviewText'],
      rating: json['rating'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      username: json['username'], // Parse username from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'serviceProviderId': serviceProviderId,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': timestamp,
      'username': username, // Include username in toJson
    };
  }
}