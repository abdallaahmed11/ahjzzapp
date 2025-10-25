import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String image;
  final double rating;
  final String price;
  final String distance;
  // (يمكن إضافة حقل category هنا إذا احتجناه لاحقاً)

  ServiceProvider({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
    required this.distance,
  });

  // **** دالة Factory جديدة لتحويل مستند Firestore إلى ServiceProvider ****
  factory ServiceProvider.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceProvider(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Provider',
      image: data['imageUrl'] ?? '', // التأكد من استخدام اسم الحقل الصحيح 'imageUrl'
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      price: data['priceIndicator'] ?? 'N/A', // التأكد من استخدام اسم الحقل الصحيح
      distance: data['distance'] ?? 'Unknown distance',
    );
  }
// ******************************************************************
}