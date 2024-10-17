import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({Key? key}) : super(key: key);

  // Fetch FAQs from Firestore
  Stream<QuerySnapshot> _fetchFAQs() {
    return FirebaseFirestore.instance.collection('FAQs').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchFAQs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching FAQs'));
          }

          final faqs = snapshot.data?.docs;

          if (faqs == null || faqs.isEmpty) {
            return const Center(child: Text('No FAQs available.'));
          }

          return ListView.builder(
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              var faq = faqs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(faq['Question'] ?? 'N/A'),
                  subtitle: Text(faq['Answer'] ?? 'N/A'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
