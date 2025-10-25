import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userName;
  final String providerName; // اسم المزود الذي تم تقييمه
  final double rating;
  final String reviewText;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.providerName,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  // دالة لتحويل بيانات Firestore إلى الموديل
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return ReviewModel(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      providerName: data['providerName'] ?? 'Unknown Provider',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: data['reviewText'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }
}