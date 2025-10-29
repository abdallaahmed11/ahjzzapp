import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// استيراد كل الموديلات المطلوبة
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/models/review_model.dart';
import 'package:ahjizzzapp/models/discount_model.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';

class DbService {
  // (مراجع الـ Collections كما هي)
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
  final CollectionReference _discountsCollection =
  FirebaseFirestore.instance.collection('discounts');


  // --- (كل الدوال السابقة كما هي) ---
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

  Future<List<ServiceProvider>> getServicesNearYou({required String city, int limit = 5}) async {
    try {
      print("DbService: Fetching nearby services for city: $city");
      Query query = _providersCollection.where('city', isEqualTo: city);
      query = query.orderBy('name').limit(limit);
      QuerySnapshot snapshot = await query.get();
      List<ServiceProvider> providers = snapshot.docs.map((doc) => ServiceProvider.fromFirestore(doc)).toList();
      print("DbService: Fetched ${providers.length} nearby services for $city.");
      return providers;
    } catch (e) {
      print("Error fetching nearby services: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for city + name query. Check Firebase console.");
      }
      return [];
    }
  }

  Future<List<TopRatedProvider>> getTopRatedProviders({required String city, int limit = 3}) async {
    try {
      print("DbService: Fetching top rated providers for city: $city");
      QuerySnapshot snapshot = await _providersCollection
          .where('isTopRated', isEqualTo: true)
          .where('city', isEqualTo: city)
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
          image: data['imageUrl'] ?? '',
        );
      }).toList();
      print("DbService: Fetched ${topProviders.length} top rated providers for $city.");
      return topProviders;
    } catch (e) {
      print("Error fetching top rated providers: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for isTopRated + city + rating query. Check Firebase console.");
      }
      return [];
    }
  }

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
      List<ServiceProvider> providers = snapshot.docs.map((doc) => ServiceProvider.fromFirestore(doc)).toList();
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

  Future<List<ProviderServiceModel>> getServicesForProvider(String providerId) async {
    try {
      print("DbService: Fetching services for provider ID: $providerId");
      QuerySnapshot snapshot = await _providersCollection.doc(providerId).collection('services').orderBy('name').get();
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

  Future<void> createUserProfile({required String uid, required String name, required String email}) async {
    try {
      await _usersCollection.doc(uid).set({
        'name': name, 'email': email, 'createdAt': FieldValue.serverTimestamp(),
        'phone': '', 'city': '', 'bio': '',
      }, SetOptions(merge: true));
      print("DbService: User profile created/updated for UID: $uid");
    } catch (e) { print("Error creating/updating user profile: $e"); throw Exception("Could not save user profile."); }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) { return doc.data() as Map<String, dynamic>?; }
      print("DbService: User profile not found for UID: $uid"); return null;
    } catch (e) { print("Error fetching user profile: $e"); return null; }
  }

  Future<void> updateUserProfile(String uid, {required String name, String? phone, String? city, String? bio}) async {
    try {
      Map<String, dynamic> dataToUpdate = {'name': name,};
      if (phone != null) dataToUpdate['phone'] = phone;
      if (city != null) dataToUpdate['city'] = city;
      if (bio != null) dataToUpdate['bio'] = bio;
      await _usersCollection.doc(uid).update(dataToUpdate);
      print("DbService: User profile updated for UID: $uid");
    } catch (e) { print("Error updating user profile: $e"); throw Exception("Could not update profile."); }
  }

  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) { Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {}; return data['name'] as String?; }
      print("DbService: User profile not found for UID: $uid"); return null;
    } catch (e) { print("Error fetching user name: $e"); return null; }
  }

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

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      print("DbService: Fetching bookings for user: $userId");
      QuerySnapshot snapshot = await _bookingsCollection .where('userId', isEqualTo: userId) .orderBy('bookingTime', descending: true) .get();
      List<BookingModel> bookings = snapshot.docs .map((doc) => BookingModel.fromFirestore(doc)) .toList();
      print("DbService: Fetched ${bookings.length} bookings for user $userId."); return bookings;
    } catch (e) { print("Error fetching user bookings: $e"); return []; }
  }

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

  // **** دالة حفظ التقييم (مُحدثة باستخدام Transaction) ****
  Future<void> submitReview({
    required String bookingId,
    required String providerId,
    required String providerName,
    required String userId,
    required String userName,
    required double rating,
    required String reviewText,
  }) async {

    // 1. تحديد المراجع للمستندات اللي هنشتغل عليها
    final DocumentReference providerDocRef = _providersCollection.doc(providerId);
    final DocumentReference reviewDocRef = _reviewsCollection.doc(); // مستند تقييم جديد
    final DocumentReference bookingDocRef = _bookingsCollection.doc(bookingId); // مستند الحجز

    print("DbService: Starting review submission transaction for booking: $bookingId");

    // 2. استخدام Transaction لضمان تنفيذ كل العمليات معًا
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {

        // 2a. قراءة البيانات الحالية لمزود الخدمة
        DocumentSnapshot providerSnapshot = await transaction.get(providerDocRef);
        if (!providerSnapshot.exists) {
          throw Exception("Provider document not found!");
        }

        Map<String, dynamic> providerData = providerSnapshot.data() as Map<String, dynamic>? ?? {};

        // جلب التقييم القديم وعدد المراجعات (مع قيم افتراضية آمنة)
        double currentRating = (providerData['rating'] as num?)?.toDouble() ?? 0.0;
        int currentReviewsCount = (providerData['reviews'] as int?) ?? 0;

        // 2b. حساب المتوسط الجديد
        // (التقييم القديم * عدد المراجعات القديم) + التقييم الجديد / (عدد المراجعات + 1)
        double newRating =
            ((currentRating * currentReviewsCount) + rating) / (currentReviewsCount + 1);
        int newReviewsCount = currentReviewsCount + 1;

        // 2c. كتابة التقييم الجديد في مجموعة 'reviews'
        transaction.set(reviewDocRef, {
          'bookingId': bookingId,
          'providerId': providerId,
          'providerName': providerName,
          'userId': userId,
          'userName': userName,
          'rating': rating,
          'reviewText': reviewText,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2d. تحديث مستند مزود الخدمة بالتقييم الجديد وعدد المراجعات الجديد
        transaction.update(providerDocRef, {
          'rating': newRating, // المتوسط الجديد
          'reviews': newReviewsCount, // العدد الجديد
        });

        // 2e. تحديث حالة الحجز إلى 'rated'
        transaction.update(bookingDocRef, {
          'status': 'rated',
        });

      });

      print("DbService: Review transaction completed successfully.");

    } catch (e) {
      print("Error submitting review transaction: $e");
      // إذا فشلت الـ Transaction، Firestore بيعمل rollback تلقائيًا
      throw Exception("Could not submit review.");
    }
  }
  // **********************************

  // (دالة updateBookingStatus كما هي - للتعامل مع الإلغاء)
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

  // (دالة getReviewsByUser كما هي)
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

  // (دالة getReviewsForProvider كما هي)
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

  // (دالة getProviderById كما هي)
  Future<ServiceProvider?> getProviderById(String providerId) async {
    try {
      print("DbService: Fetching provider by ID: $providerId");
      DocumentSnapshot doc = await _providersCollection.doc(providerId).get();
      if (doc.exists) {
        return ServiceProvider.fromFirestore(doc);
      } else {
        print("DbService: Provider not found for ID: $providerId");
        return null;
      }
    } catch (e) {
      print("Error fetching provider by ID: $e");
      return null;
    }
  }

  // (دالة searchProviders كما هي)
  Future<List<ServiceProvider>> searchProviders(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      print("DbService: Searching providers for query: $query");
      QuerySnapshot snapshot = await _providersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();
      List<ServiceProvider> providers = snapshot.docs
          .map((doc) => ServiceProvider.fromFirestore(doc))
          .toList();
      print("DbService: Found ${providers.length} providers for query '$query'.");
      return providers;
    } catch (e) {
      print("Error searching providers: $e");
      if (e is FirebaseException && e.code == 'failed-precondition') {
        print("Firestore Index potentially missing for searchProviders query (on 'name' field). Check Firebase console.");
      }
      return [];
    }
  }

  // (دالة validateDiscountCode كما هي)
  Future<DiscountModel?> validateDiscountCode(String code) async {
    try {
      print("DbService: Validating discount code: $code");
      DocumentSnapshot doc = await _discountsCollection.doc(code).get();
      if (doc.exists) {
        DiscountModel discount = DiscountModel.fromFirestore(doc);
        if (discount.isActive) {
          print("DbService: Code '$code' is valid. Discount: ${discount.discountPercentage}%");
          return discount;
        } else {
          print("DbService: Code '$code' is no longer active.");
          return null;
        }
      } else {
        print("DbService: Code '$code' does not exist.");
        return null;
      }
    } catch (e) {
      print("Error validating discount code: $e");
      return null;
    }
  }
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        // الدور الافتراضي يكون 'user' إذا لم يكن الحقل موجودًا
        return data['role'] as String? ?? 'user';
      }
      return 'guest'; // إذا لم يجد المستخدم (رغم أنه يجب أن يكون موجودًا بعد اللوجين)
    } catch (e) {
      print("Error fetching user role: $e");
      return 'user';
    }
  }
  // ************
  Future<void> addServiceProvider({
    required String name,
    required String category,
    required String city,
    required String imageUrl,
    required String priceIndicator,
    required String distance,
    double rating = 0.0, // تقييم مبدئي
    int reviews = 0,     // عدد مراجعات مبدئي
    bool isTopRated = false, // افتراضي
  }) async {
    try {
      print("DbService: Admin adding new provider: $name");
      await _providersCollection.add({
        'name': name,
        'category': category,
        'city': city,
        'imageUrl': imageUrl,
        'priceIndicator': priceIndicator,
        'distance': distance,
        'rating': rating,
        'reviews': reviews,
        'isTopRated': isTopRated,
        'createdAt': FieldValue.serverTimestamp(), // اختياري: لمعرفة وقت الإضافة
      });
      print("DbService: Provider added successfully.");
    } catch (e) {
      print("Error adding provider: $e");
      throw Exception("Could not add provider.");
    }
  }
  // **********************************************
  Future<void> addServiceToProvider({
    required String providerId,
    required String serviceName,
    required String price,
    required String duration,
  }) async {
    try {
      print("DbService: Admin adding service '$serviceName' to $providerId");
      // الوصول للـ Subcollection وإضافة مستند جديد
      await _providersCollection
          .doc(providerId)
          .collection('services')
          .add({
        'name': serviceName,
        'price': price,
        'duration': duration,
      });
      print("DbService: Service added successfully.");
    } catch (e) {
      print("Error adding service: $e");
      throw Exception("Could not add service.");
    }
  }
  // **********************************

  // **** دالة جديدة: حذف خدمة من مزود ****
  Future<void> deleteServiceFromProvider({
    required String providerId,
    required String serviceId,
  }) async {
    try {
      print("DbService: Admin deleting service '$serviceId' from $providerId");
      await _providersCollection
          .doc(providerId)
          .collection('services')
          .doc(serviceId) // تحديد مستند الخدمة
          .delete(); // حذفه
      print("DbService: Service deleted successfully.");
    } catch (e) {
      print("Error deleting service: $e");
      throw Exception("Could not delete service.");
    }
  }
  // **********************************
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