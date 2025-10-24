import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import necessary models
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // Contains ProviderServiceModel
// Import services needed
import 'package:ahjizzzapp/services/auth_service.dart'; // To get current user ID
// import 'package:ahjizzzapp/services/db_service.dart'; // To save the booking

enum PaymentMethod { payOnArrival, payOnline }

class BookingPaymentViewModel extends ChangeNotifier {
  // final DbService _dbService; // To save booking
  final AuthService _authService; // To get user ID

  // Data received from previous screen
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  // State for this screen
  final notesController = TextEditingController();
  final discountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.payOnArrival; // Default
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Formatted date and time for display
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(selectedDate);
  String get formattedTime => selectedTime;

  // BookingPaymentViewModel(this._dbService, this._authService, { // Future constructor
  BookingPaymentViewModel(this._authService, { // Temporary constructor
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  });

  // Action: Select payment method
  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  // Action: Confirm and save the booking
  Future<bool> confirmBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Get current user ID
      // final userId = _authService.getCurrentUserId(); // Assuming AuthService has this method
      // if (userId == null) throw Exception("User not logged in");

      // TODO: Implement logic to save booking details to Firestore using _dbService
      // await _dbService.createBooking(
      //   userId: userId,
      //   providerId: provider.id,
      //   serviceId: service.id,
      //   dateTime: combineDateAndTime(selectedDate, selectedTime), // Helper to combine date & time
      //   price: service.price,
      //   notes: notesController.text,
      //   paymentMethod: _selectedPaymentMethod.name, // Save as string 'payOnArrival' or 'payOnline'
      //   discountCode: discountController.text,
      // );

      print("Booking Confirmed!");
      print(" Provider: ${provider.name}");
      print(" Service: ${service.name}");
      print(" Date: $formattedDate");
      print(" Time: $formattedTime");
      print(" Payment: ${_selectedPaymentMethod.name}");
      print(" Notes: ${notesController.text}");
      await Future.delayed(Duration(seconds: 1)); // Simulate network call

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to confirm booking: ${e.toString()}";
      notifyListeners();
      return false; // Failed
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    discountController.dispose();
    super.dispose();
  }
}

// Helper function (you can place this in a utility file later)
// DateTime combineDateAndTime(DateTime date, String timeString) {
//   // Parse timeString (e.g., "9:30 AM") into TimeOfDay or hours/minutes
//   // Then combine with the date part
//   // Example (needs robust parsing):
//   try {
//      final format = DateFormat("h:mm a"); // Assumes format like "9:30 AM"
//      final time = format.parse(timeString);
//      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
//   } catch(e){
//      return date; // Fallback
//   }
// }