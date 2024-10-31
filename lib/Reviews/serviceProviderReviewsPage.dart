import 'package:finders_v1_1/Reviews/reviewModel.dart';
import 'package:finders_v1_1/Reviews/reviewViewModel.dart';
import 'package:flutter/material.dart';

class ServiceProviderReviewsPage extends StatelessWidget {
  final String serviceProviderId;
  final ReviewViewModel _reviewViewModel = ReviewViewModel();

  ServiceProviderReviewsPage({super.key, required this.serviceProviderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Service Provider Reviews")),
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewViewModel.getReviews(serviceProviderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews"));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(child: Text("No reviews available"));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                title: Text("${review.rating} Stars"),
                subtitle: Text(review.reviewText),
                trailing: Text(
                  "${review.timestamp.toLocal()}".split(' ')[0],
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}