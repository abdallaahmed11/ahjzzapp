// (يمكن إضافة حقول أخرى لاحقاً مثل providerId, userId, statusEnum)
enum BookingStatus { upcoming, completed, cancelled }

class BookingModel {
  final String id;
  final String providerName; // e.g., "Sam's Barbershop" [cite: 111]
  final String serviceName;  // e.g., "Men's Haircut & Beard Trim" [cite: 112]
  final DateTime dateTime;   // e.g., Thu, 23 Oct, 2:00 PM [cite: 113, 114]
  final String price;        // e.g., "$35" [cite: 115]
  final BookingStatus status; // To categorize the booking

  BookingModel({
    required this.id,
    required this.providerName,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    required this.status,
  });

// (اختياري: دوال لتحويل البيانات من وإلى Firestore)
// factory BookingModel.fromFirestore(Map<String, dynamic> data, String documentId) { ... }
// Map<String, dynamic> toFirestore() { ... }
}