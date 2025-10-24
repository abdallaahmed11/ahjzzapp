import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // Import DbService
import 'package:ahjizzzapp/services/auth_service.dart'; // Import AuthService

class MyBookingsViewModel extends ChangeNotifier {
  final DbService _dbService; // Add DbService
  final AuthService _authService; // Add AuthService

  // State
  bool _isLoading = false;
  List<BookingModel> _allBookings = [];
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Filtered lists based on status string
  List<BookingModel> get upcomingBookings =>
      _allBookings.where((b) => b.status == 'upcoming').toList();
  List<BookingModel> get completedBookings =>
      _allBookings.where((b) => b.status == 'completed').toList();
  List<BookingModel> get cancelledBookings =>
      _allBookings.where((b) => b.status == 'cancelled').toList();

  // Constructor requires services
  MyBookingsViewModel(this._dbService, this._authService) {
    fetchBookings(); // Fetch bookings on initialization
  }

  // Fetch bookings for the current user from Firestore
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get current User ID
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      // 2. Call DbService to get user bookings
      _allBookings = await _dbService.getUserBookings(userId);

    } catch (e) {
      print("Error fetching bookings in ViewModel: $e");
      _errorMessage = "Could not load your bookings.";
      _allBookings = []; // Clear list on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Update UI
    }
  }

  // Cancel booking action (placeholder for actual implementation)
  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true; // Can use a specific loading state for cancellation
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Call DbService to update booking status to 'cancelled'
      // await _dbService.updateBookingStatus(bookingId, 'cancelled');
      print("Cancelling booking $bookingId (Simulated)");
      await Future.delayed(Duration(milliseconds: 500)); // Simulate

      // Refresh the list to show the change
      await fetchBookings(); // This will handle loading state and notifyListeners

    } catch(e){
      print("Error cancelling booking: $e");
      _errorMessage = "Could not cancel booking.";
      // Need to set isLoading false here if fetchBookings fails immediately
      _isLoading = false;
      notifyListeners();
    }
  }
}