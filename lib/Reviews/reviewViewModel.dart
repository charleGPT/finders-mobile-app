import 'package:cloud_firestore/cloud_firestore.dart';
import 'reviewModel.dart';

class ReviewViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.collection('Reviews').add(review.toJson());
    } catch (e) {
      print("Error adding review: $e");
    }
  }

  Future<List<ReviewModel>> getReviews(String serviceProviderId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Reviews')
          .where('serviceProviderId', isEqualTo: serviceProviderId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error retrieving reviews: $e");
      return [];
    }
  }
}
