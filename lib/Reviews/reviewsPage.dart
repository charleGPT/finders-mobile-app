import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finders_v1_1/Reviews/reviewModel.dart';
import 'package:finders_v1_1/Reviews/reviewViewModel.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final String clientId;
  final String serviceProviderId;
  final String username;

  const ReviewPage({
    super.key,
    required this.clientId,
    required this.serviceProviderId,
    required this.username,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  String _reviewText = '';
  int _rating = 5;
  bool _loading = false;
  final ReviewViewModel _reviewViewModel = ReviewViewModel();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReviewModel> _reviews = []; // List to hold the reviews

  @override
  void initState() {
    super.initState();
    _loadReviews(); // Load reviews when the page is initialized
  }

  Future<void> _loadReviews() async {
    List<ReviewModel> reviews = await getReviews(widget.serviceProviderId);
    setState(() {
      _reviews = reviews; // Update the state with retrieved reviews
    });
  }

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
      });

      ReviewModel review = ReviewModel(
        clientId: widget.clientId,
        serviceProviderId: widget.serviceProviderId,
        reviewText: _reviewText,
        rating: _rating,
        timestamp: DateTime.now(),
        username: widget.username,
      );

      await _reviewViewModel.addReview(review);
      _loadReviews(); // Reload reviews after submission

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Review"),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return ListTile(
                          title: Text(review.username),
                          subtitle: Text(review.reviewText),
                          trailing: Text(
                              '${review.rating} Star${review.rating > 1 ? 's' : ''}'),
                        );
                      },
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Review'),
                          maxLines: 5,
                          onSaved: (value) => _reviewText = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a review' : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          value: _rating,
                          decoration: InputDecoration(labelText: 'Rating'),
                          items: List.generate(5, (index) {
                            int value = index + 1;
                            return DropdownMenuItem(
                              value: value,
                              child: Text('$value Star${value > 1 ? 's' : ''}'),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _rating = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitReview,
                          child: Text('Submit Review'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
