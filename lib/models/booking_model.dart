import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for display purposes in the app
enum BookingStatus { upcoming, completed, cancelled }

class BookingModel {
  final String id;
  final String providerId; // <-- تمت إضافة هذا الحقل
  final String providerName;
  final String serviceName;
  final DateTime dateTime; // Used for display
  final String price;
  final String status; // Read as string from Firestore

  BookingModel({
    required this.id,
    required this.providerId, // <-- تمت إضافته
    required this.providerName,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    required this.status,
  });

  // Factory constructor to create a BookingModel from a Firestore document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Safely convert Firestore Timestamp to Dart DateTime
    DateTime bookingDateTime =
        (data['bookingTime'] as Timestamp?)?.toDate() ?? DateTime(1970);

    return BookingModel(
      id: doc.id, // Use Firestore document ID
      providerId: data['providerId'] ?? 'unknown_id', // <-- تمت إضافته
      providerName: data['providerName'] ?? 'Unknown Provider',
      serviceName: data['serviceName'] ?? 'Unknown Service',
      dateTime: bookingDateTime,
      price: data['price'] ?? 'N/A',
      status: data['status'] ?? 'unknown',
    );
  }
}