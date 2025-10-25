import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// استيراد كل الموديلات المطلوبة
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/models/review_model.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final CollectionReference _reviewsCollection =
  FirebaseFirestore.instance.collection('reviews');


  // --- دوال جلب البيانات (لشاشة Home وغيرها) ---

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
          image: data['imageUrl'] ?? '', // <-- إضافة جلب رابط الصورة
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

  // دالة جلب الخدمات الخاصة بمزود خدمة معين
  Future<List<ProviderServiceModel>> getServicesForProvider(String providerId) async {
    try {
      print("DbService: Fetching services for provider ID: $providerId");
      QuerySnapshot snapshot = await _providersCollection
          .doc(providerId)
          .collection('services')
          .orderBy('name')
          .get();

      List<ProviderServiceModel> services = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return ProviderServiceModel(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Service',
          price: data['price'] ?? 'N/A',
          duration: data['duration'] ?? 'Unknown',
        );
      }).toList();

      print("DbService: Fetched ${services.length} services for provider $providerId.");
      return services;

    } catch (e) {
      print("Error fetching services for provider $providerId: $e");
      return [];
    }
  }

  // --- دوال المستخدمين (User Profile) ---

  // (مُعدلة: لإضافة حقول افتراضية فارغة)
  Future<void> createUserProfile({required String uid, required String name, required String email}) async {
    try {
      await _usersCollection.doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'phone': '', // <-- إضافة حقل هاتف فارغ
        'city': '',  // <-- إضافة حقل مدينة فارغ
        'bio': '',   // <-- إضافة حقل نبذة فارغ
      }, SetOptions(merge: true));
      print("DbService: User profile created/updated for UID: $uid");
    } catch (e) { print("Error creating/updating user profile: $e"); throw Exception("Could not save user profile."); }
  }

  // دالة جلب كل بيانات المستخدم
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?; // إرجاع كل البيانات
      }
      print("DbService: User profile not found for UID: $uid");
      return null;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // تعديل دالة تحديث بيانات المستخدم
  Future<void> updateUserProfile(String uid, {
    required String name,
    String? phone,
    String? city,
    String? bio,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'name': name,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (bio != null) 'bio': bio,
      };

      await _usersCollection.doc(uid).update(dataToUpdate);
      print("DbService: User profile updated for UID: $uid");

    } catch (e) {
      print("Error updating user profile: $e");
      throw Exception("Could not update profile.");
    }
  }

  // دالة جلب اسم المستخدم (تستخدمها ViewModels أخرى)
  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return data['name'] as String?;
      }
      print("DbService: User profile not found for UID: $uid"); return null;
    } catch (e) { print("Error fetching user name: $e"); return null; }
  }


  // --- دوال الحجوزات (Bookings) ---

  // دالة لإنشاء حجز جديد
  Future<DocumentReference> createBooking({
    required String userId,
    required String providerId,
    required String providerName,
    required String serviceId,
    required String serviceName,
    required DateTime dateTime,
    required String price,
    String? notes,
    required String paymentMethod,
    String? discountCode,
    String status = 'upcoming',
  }) async {
    try {
      print("DbService: Creating booking in Firestore...");
      DocumentReference docRef = await _bookingsCollection.add({
        'userId': userId,
        'providerId': providerId,
        'providerName': providerName,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'bookingTime': Timestamp.fromDate(dateTime),
        'price': price,
        'status': status,
        'notes': notes,
        'paymentMethod': paymentMethod,
        'discountCode': discountCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("DbService: Booking created successfully with ID: ${docRef.id}"); return docRef;
    } catch (e) { print("Error creating booking: $e"); throw Exception("Could not create booking."); }
  }

  // دالة لجلب حجوزات المستخدم
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      print("DbService: Fetching bookings for user: $userId");
      QuerySnapshot snapshot = await _bookingsCollection .where('userId', isEqualTo: userId) .orderBy('bookingTime', descending: true) .get();
      List<BookingModel> bookings = snapshot.docs .map((doc) => BookingModel.fromFirestore(doc)) .toList();
      print("DbService: Fetched ${bookings.length} bookings for user $userId."); return bookings;
    } catch (e) { print("Error fetching user bookings: $e"); return []; }
  }

  // دالة جلب المواعيد المحجوزة
  Future<List<String>> getBookedTimeSlots(String providerId, DateTime date) async {
    try {
      print("DbService: Fetching booked slots for provider $providerId on $date");
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot snapshot = await _bookingsCollection
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'upcoming')
          .where('bookingTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('bookingTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      List<String> bookedSlots = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        Timestamp bookingTimestamp = data['bookingTime'] as Timestamp;
        DateTime bookingTime = bookingTimestamp.toDate();
        return DateFormat('h:mm a').format(bookingTime);
      }).toList();

      print("DbService: Found ${bookedSlots.length} booked slots: $bookedSlots");
      return bookedSlots;

    } catch (e) {
      print("Error fetching booked slots: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for getBookedTimeSlots query. Check Firebase console for a link to create it.");
      }
      return [];
    }
  }

  // --- دوال التقييمات (Reviews) ---

  // دالة حفظ تقييم جديد
  Future<void> submitReview({
    required String bookingId,
    required String providerId,
    required String providerName,
    required String userId,
    required String userName,
    required double rating,
    required String reviewText,
  }) async {
    try {
      print("DbService: Submitting review for booking: $bookingId");
      await _reviewsCollection.add({
        'bookingId': bookingId,
        'providerId': providerId,
        'providerName': providerName,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("DbService: Review submitted successfully.");
      // TODO: (Advanced) Update average rating on serviceProvider document
    } catch (e) {
      print("Error submitting review: $e");
      throw Exception("Could not submit review.");
    }
  }

  // دالة تحديث حالة الحجز
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      print("DbService: Updating booking $bookingId status to $newStatus");
      await _bookingsCollection.doc(bookingId).update({
        'status': newStatus,
      });
      print("DbService: Booking status updated.");
    } catch (e) {
      print("Error updating booking status: $e");
      throw Exception("Could not update booking status.");
    }
  }

  // دالة جلب تقييمات المستخدم
  Future<List<ReviewModel>> getReviewsByUser(String userId, {int limit = 20}) async {
    try {
      print("DbService: Fetching reviews for user ID: $userId");
      QuerySnapshot snapshot = await _reviewsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      List<ReviewModel> reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
      print("DbService: Fetched ${reviews.length} reviews for user $userId.");
      return reviews;
    } catch (e) {
      print("Error fetching reviews for user $userId: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for getReviewsByUser query. Check Firebase console for a link to create it.");
      }
      return [];
    }
  }

  // دالة جلب تقييمات المزود
  Future<List<ReviewModel>> getReviewsForProvider(String providerId, {int limit = 5}) async {
    try {
      print("DbService: Fetching reviews for provider ID: $providerId");
      QuerySnapshot snapshot = await _reviewsCollection
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      List<ReviewModel> reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
      print("DbService: Fetched ${reviews.length} reviews for provider $providerId.");
      return reviews;
    } catch (e) {
      print("Error fetching reviews for provider $providerId: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for getReviewsForProvider query. Check Firebase console for a link to create it.");
      }
      return [];
    }
  }

  // دالة جلب مزود خدمة واحد بالـ ID
  Future<ServiceProvider?> getProviderById(String providerId) async {
    try {
      print("DbService: Fetching provider by ID: $providerId");
      DocumentSnapshot doc = await _providersCollection.doc(providerId).get();
      if (doc.exists) {
        return ServiceProvider.fromFirestore(doc); // استخدام الـ factory constructor
      } else {
        print("DbService: Provider not found for ID: $providerId");
        return null;
      }
    } catch (e) {
      print("Error fetching provider by ID: $e");
      return null;
    }
  }

  // --- الدوال المساعدة (Helper Functions) ---
  // (لتحويل النصوص من Firestore إلى أيقونات وألوان)
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