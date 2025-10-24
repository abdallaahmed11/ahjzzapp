import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Import all necessary models
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
import 'package:ahjizzzapp/models/booking_model.dart';

class DbService {
  // Collection References for Firestore
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');
  final CollectionReference _providersCollection =
  FirebaseFirestore.instance.collection('serviceProviders');
  final CollectionReference _bookingsCollection = // Reference for bookings
  FirebaseFirestore.instance.collection('bookings');
  final CollectionReference _usersCollection = // Reference for users
  FirebaseFirestore.instance.collection('users');

  // --- Data Fetching Functions ---

  // Fetches categories from Firestore, ordered by 'order' field
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
      return []; // Return empty list on error
    }
  }

  // Fetches a limited list of service providers (e.g., for "Services Near You")
  Future<List<ServiceProvider>> getServicesNearYou({int limit = 5}) async {
    try {
      print("DbService: Fetching nearby services from Firestore...");
      // Simple fetch, ordered by name, limited count. Replace with location logic later.
      QuerySnapshot snapshot = await _providersCollection
          .orderBy('name')
          .limit(limit)
          .get();

      List<ServiceProvider> providers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return ServiceProvider(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Provider',
          image: data['imageUrl'] ?? '', // Default empty string if missing
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0, // Safe number conversion
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

  // Fetches top-rated service providers (where isTopRated is true)
  Future<List<TopRatedProvider>> getTopRatedProviders({int limit = 3}) async {
    try {
      print("DbService: Fetching top rated providers from Firestore...");
      QuerySnapshot snapshot = await _providersCollection
          .where('isTopRated', isEqualTo: true) // Filter by boolean field
          .orderBy('rating', descending: true) // Order by rating descending
          .limit(limit)
          .get();

      List<TopRatedProvider> topProviders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        // Ensure the 'reviews' field is handled correctly, even if missing
        return TopRatedProvider(
          id: doc.id,
          name: data['name'] ?? 'Unnamed Provider',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviews: (data['reviews'] as int?) ?? 0, // Get review count safely, default to 0
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

  // --- User Profile Functions ---

  // Creates/updates a user profile document in the 'users' collection
  Future<void> createUserProfile({
    required String uid, // User ID from Firebase Auth
    required String name,
    required String email,
  }) async {
    try {
      // Use set with merge: true to create or update without overwriting other fields
      await _usersCollection.doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), // Record creation time
        // Add other fields like phone number, profile picture URL later
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data if any
      print("DbService: User profile created/updated for UID: $uid");
    } catch (e) {
      print("Error creating/updating user profile: $e");
      throw Exception("Could not save user profile."); // Propagate error
    }
  }

  // Fetches the user's name from their profile document
  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return data['name'] as String?; // Return name if exists
      }
      print("DbService: User profile not found for UID: $uid");
      return null; // User document doesn't exist
    } catch (e) {
      print("Error fetching user name: $e");
      return null; // Return null on error
    }
  }

  // --- Booking Functions ---

  // Creates a new booking document in the 'bookings' collection
  Future<DocumentReference> createBooking({ // Return DocumentReference
    required String userId,
    required String providerId,
    required String providerName,
    required String serviceId,
    required String serviceName,
    required DateTime dateTime, // DateTime from the app
    required String price,
    String? notes,
    required String paymentMethod, // 'payOnArrival' or 'payOnline'
    String? discountCode,
    String status = 'upcoming', // Default status for new bookings
  }) async {
    try {
      print("DbService: Creating booking in Firestore...");
      // Add the booking data to the collection
      DocumentReference docRef = await _bookingsCollection.add({
        'userId': userId,
        'providerId': providerId,
        'providerName': providerName,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'bookingTime': Timestamp.fromDate(dateTime), // Convert DateTime to Firestore Timestamp
        'price': price,
        'status': status,
        'notes': notes,
        'paymentMethod': paymentMethod,
        'discountCode': discountCode,
        'createdAt': FieldValue.serverTimestamp(), // Automatically add creation timestamp
      });
      print("DbService: Booking created successfully with ID: ${docRef.id}");
      return docRef; // Return the reference to the newly created document
    } catch (e) {
      print("Error creating booking: $e");
      throw Exception("Could not create booking."); // Propagate error
    }
  }

  // Fetches all bookings for a specific user, ordered by booking time
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      print("DbService: Fetching bookings for user: $userId");
      QuerySnapshot snapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId) // Filter bookings by userId
          .orderBy('bookingTime', descending: true) // Order by booking time, newest first
          .get();

      // Map Firestore documents to BookingModel objects
      List<BookingModel> bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc)) // Use factory constructor
          .toList();

      print("DbService: Fetched ${bookings.length} bookings for user $userId.");
      return bookings;
    } catch (e) {
      print("Error fetching user bookings: $e");
      return []; // Return empty list on error
    }
  }

  // TODO: Add function to update booking status (e.g., for cancellation)
  // Future<void> updateBookingStatus(String bookingId, String newStatus) async {
  //   try {
  //     await _bookingsCollection.doc(bookingId).update({'status': newStatus});
  //     print("DbService: Updated booking $bookingId status to $newStatus");
  //   } catch (e) {
  //     print("Error updating booking status: $e");
  //     throw Exception("Could not update booking status.");
  //   }
  // }


  // --- Helper Functions ---
  // (These remain the same)

  // Converts icon name string (from Firestore) to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'cut': return Icons.content_cut;
      case 'cleaning': return Icons.cleaning_services;
      case 'car': return Icons.local_car_wash;
      case 'build': return Icons.build;
      case 'spa': return Icons.spa;
      default: return Icons.category; // Default icon
    }
  }

  // Converts hex color code string (from Firestore) to Color object
  Color _getColorFromString(String colorCode) {
    try {
      final String hexCode = colorCode.replaceAll('#', '');
      // Add 'FF' for alpha (opacity) and parse hex
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      print("Error parsing color code '$colorCode': $e");
      return Colors.grey; // Default color on error
    }
  }
}