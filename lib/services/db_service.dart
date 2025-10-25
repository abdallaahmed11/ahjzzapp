import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// استيراد كل الموديلات المطلوبة
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
// استيراد الموديل الجديد للخدمة
// (ملاحظة: نقلنا تعريف ProviderServiceModel لملف الـ ViewModel الخاص به لتقليل الاعتماديات)
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';

class DbService {
  // المراجع للمجموعات (Collections) في Firestore
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');
  final CollectionReference _providersCollection =
  FirebaseFirestore.instance.collection('serviceProviders');
  final CollectionReference _bookingsCollection =
  FirebaseFirestore.instance.collection('bookings');
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // --- دوال جلب البيانات (لشاشة Home) ---

  // دالة جلب الفئات
  Future<List<QuickCategory>> getCategories() async {
    try {
      print("DbService: Fetching categories from Firestore...");
      QuerySnapshot snapshot = await _categoriesCollection.orderBy('order').get();
      List<QuickCategory> categories = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return QuickCategory(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Category',
          icon: _getIconFromString(data['iconName'] ?? 'default'),
          color: _getColorFromString(data['colorCode'] ?? '#CCCCCC'),
        );
      }).toList();
      print("DbService: Fetched ${categories.length} categories successfully.");
      return categories;
    } catch (e) {
      print("Error fetching categories from Firestore: $e");
      return [];
    }
  }

  // دالة جلب الخدمات القريبة
  Future<List<ServiceProvider>> getServicesNearYou({int limit = 5}) async {
    try {
      print("DbService: Fetching nearby services from Firestore...");
      QuerySnapshot snapshot = await _providersCollection
          .orderBy('name')
          .limit(limit)
          .get();
      List<ServiceProvider> providers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return ServiceProvider(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Provider',
          image: data['imageUrl'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          price: data['priceIndicator'] ?? 'N/A',
          distance: data['distance'] ?? 'Unknown distance',
        );
      }).toList();
      print("DbService: Fetched ${providers.length} nearby services.");
      return providers;
    } catch (e) {
      print("Error fetching nearby services: $e");
      return [];
    }
  }

  // دالة جلب الأعلى تقييماً
  Future<List<TopRatedProvider>> getTopRatedProviders({int limit = 3}) async {
    try {
      print("DbService: Fetching top rated providers from Firestore...");
      QuerySnapshot snapshot = await _providersCollection
          .where('isTopRated', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      List<TopRatedProvider> topProviders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return TopRatedProvider(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Provider',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviews: (data['reviews'] as int?) ?? 0,
          category: data['category'] ?? 'General',
          price: data['priceIndicator'] ?? 'N/A',
        );
      }).toList();
      print("DbService: Fetched ${topProviders.length} top rated providers.");
      return topProviders;
    } catch (e) {
      print("Error fetching top rated providers: $e");
      return [];
    }
  }

  // دالة جلب المزودين حسب الفئة
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryName, {String? sortBy, int limit = 10}) async {
    try {
      print("DbService: Fetching providers for category: $categoryName");
      Query query = _providersCollection
          .where('category', isEqualTo: categoryName);

      if (sortBy == 'Top Rated') {
        query = query.orderBy('rating', descending: true);
      } else {
        query = query.orderBy('name');
      }
      query = query.limit(limit);
      QuerySnapshot snapshot = await query.get();

      List<ServiceProvider> providers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return ServiceProvider(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Provider',
          image: data['imageUrl'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          price: data['priceIndicator'] ?? 'N/A',
          distance: data['distance'] ?? 'Unknown distance',
        );
      }).toList();

      print("DbService: Fetched ${providers.length} providers for category $categoryName.");
      return providers;

    } catch (e) {
      print("Error fetching providers by category '$categoryName': $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for category query. Check Firebase console for a link to create it.");
      }
      return [];
    }
  }

  // **** دالة جديدة: جلب الخدمات الخاصة بمزود خدمة معين ****
  Future<List<ProviderServiceModel>> getServicesForProvider(String providerId) async {
    try {
      print("DbService: Fetching services for provider ID: $providerId");

      // 1. الوصول للمجموعة الفرعية "services" جوه مستند المزود
      QuerySnapshot snapshot = await _providersCollection
          .doc(providerId) // تحديد مستند المزود
          .collection('services') // الدخول للمجموعة الفرعية "services"
          .orderBy('name') // (اختياري: ترتيب الخدمات أبجديًا)
          .get();

      // 2. تحويل المستندات إلى قائمة ProviderServiceModel
      List<ProviderServiceModel> services = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        // استخدام الموديل المستورد من ProviderDetailsViewModel
        return ProviderServiceModel(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Service',
          price: data['price'] ?? 'N/A',
          duration: data['duration'] ?? 'Unknown',
        );
      }).toList();

      print("DbService: Fetched ${services.length} services for provider $providerId.");
      return services; // إرجاع قائمة الخدمات

    } catch (e) {
      print("Error fetching services for provider $providerId: $e");
      return []; // إرجاع قائمة فارغة عند حدوث خطأ
    }
  }
  // ******************************************************


  // --- دوال المستخدمين (User Profile) ---
  Future<void> createUserProfile({required String uid, required String name, required String email}) async {
    try {
      await _usersCollection.doc(uid).set({
        'name': name, 'email': email, 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("DbService: User profile created/updated for UID: $uid");
    } catch (e) { print("Error creating/updating user profile: $e"); throw Exception("Could not save user profile."); }
  }
  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) { Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {}; return data['name'] as String?; }
      print("DbService: User profile not found for UID: $uid"); return null;
    } catch (e) { print("Error fetching user name: $e"); return null; }
  }

  // --- دوال الحجوزات (Bookings) ---
  Future<DocumentReference> createBooking({ required String userId, required String providerId, required String providerName, required String serviceId, required String serviceName, required DateTime dateTime, required String price, String? notes, required String paymentMethod, String? discountCode, String status = 'upcoming', }) async {
    try {
      print("DbService: Creating booking in Firestore...");
      DocumentReference docRef = await _bookingsCollection.add({
        'userId': userId, 'providerId': providerId, 'providerName': providerName,
        'serviceId': serviceId, 'serviceName': serviceName,
        'bookingTime': Timestamp.fromDate(dateTime), 'price': price, 'status': status,
        'notes': notes, 'paymentMethod': paymentMethod, 'discountCode': discountCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("DbService: Booking created successfully with ID: ${docRef.id}"); return docRef;
    } catch (e) { print("Error creating booking: $e"); throw Exception("Could not create booking."); }
  }
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      print("DbService: Fetching bookings for user: $userId");
      QuerySnapshot snapshot = await _bookingsCollection .where('userId', isEqualTo: userId) .orderBy('bookingTime', descending: true) .get();
      List<BookingModel> bookings = snapshot.docs .map((doc) => BookingModel.fromFirestore(doc)) .toList();
      print("DbService: Fetched ${bookings.length} bookings for user $userId."); return bookings;
    } catch (e) { print("Error fetching user bookings: $e"); return []; }
  }
  // TODO: Add function to update booking status


  // --- الدوال المساعدة (Helper Functions) ---
  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'cut': return Icons.content_cut;
      case 'cleaning': return Icons.cleaning_services;
      case 'car': return Icons.local_car_wash;
      case 'build': return Icons.build;
      case 'spa': return Icons.spa;
      default: return Icons.category;
    }
  }
  Color _getColorFromString(String colorCode) {
    try {
      final String hexCode = colorCode.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) { print("Error parsing color code '$colorCode': $e"); return Colors.grey; }
  }
}