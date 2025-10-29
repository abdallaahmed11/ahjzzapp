import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountModel {
  final String id; // (هو نفسه كود الخصم, e.g., "WELCOME10")
  final double discountPercentage;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.discountPercentage,
    required this.isActive,
  });

  // دالة لتحويل بيانات Firestore إلى الموديل
  factory DiscountModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return DiscountModel(
      id: doc.id,
      discountPercentage: (data['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] ?? false,
    );
  }
}