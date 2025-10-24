import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import necessary models
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
// Import services needed
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// Enum for payment choices
enum PaymentMethod { payOnArrival, payOnline }

// Helper function to combine Date and Time string
DateTime combineDateAndTime(DateTime date, String timeString) {
  try {
    final format = DateFormat("h:mm a");
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  } catch(e){
    print("Error parsing time string '$timeString': $e");
    return DateTime(date.year, date.month, date.day); // Fallback
  }
}

class BookingPaymentViewModel extends ChangeNotifier {
  // Services
  final DbService _dbService;
  final AuthService _authService;

  // Data from previous screen
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  // State
  final notesController = TextEditingController();
  final discountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.payOnArrival;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(selectedDate);
  String get formattedTime => selectedTime;

  // Constructor
  BookingPaymentViewModel(this._dbService, this._authService, {
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  });

  // Actions
  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  Future<bool> confirmBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get User ID
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      // 2. Combine Date & Time
      final DateTime bookingDateTime = combineDateAndTime(selectedDate, selectedTime);

      // 3. Call DbService to create booking in Firestore
      await _dbService.createBooking(
        userId: userId,
        providerId: provider.id,
        providerName: provider.name,
        serviceId: service.id,
        serviceName: service.name,
        dateTime: bookingDateTime,
        price: service.price,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        paymentMethod: _selectedPaymentMethod.name,
        discountCode: discountController.text.trim().isEmpty ? null : discountController.text.trim(),
        status: 'upcoming',
      );

      print("Booking Saved to Firestore successfully!");
      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      print("Error confirming booking in ViewModel: $e");
      _isLoading = false;
      _errorMessage = "An error occurred: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false; // Failure
    }
  }

  // Cleanup
  @override
  void dispose() {
    notesController.dispose();
    discountController.dispose();
    super.dispose();
  }
}