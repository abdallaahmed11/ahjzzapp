import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// Import the models needed
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // Contains ProviderServiceModel
// import 'package:ahjizzzapp/services/db_service.dart'; // To fetch available slots
import 'package:ahjizzzapp/views/booking_payment_view.dart';
class TimeSelectionViewModel extends ChangeNotifier {
  // final DbService _dbService; // To fetch real data
  final ServiceProvider provider;
  final ProviderServiceModel service;

  bool _isLoading = false;
  List<DateTime> _availableDates = []; // Dates for the next week, for example
  List<String> _availableTimes = []; // Time slots for the selected date
  DateTime? _selectedDate;
  String? _selectedTime;

  bool get isLoading => _isLoading;
  List<DateTime> get availableDates => _availableDates;
  List<String> get availableTimes => _availableTimes;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;

  // TimeSelectionViewModel(this._dbService, this.provider, this.service) { // Future constructor
  TimeSelectionViewModel(this.provider, this.service) { // Temporary constructor
    _generateAvailableDates();
    // Select the first date by default and fetch its times
    if (_availableDates.isNotEmpty) {
      selectDate(_availableDates.first);
    }
  }

  // Generate dates for the next 7 days (example)
  void _generateAvailableDates() {
    final now = DateTime.now();
    _availableDates = List.generate(7, (index) => now.add(Duration(days: index)));
    notifyListeners();
  }

  // Fetch available time slots for a given date
  Future<void> fetchAvailableTimes(DateTime date) async {
    _isLoading = true;
    _availableTimes = []; // Clear previous times
    _selectedTime = null; // Reset time selection
    notifyListeners();

    // TODO: Replace with real data fetching from Firestore based on provider, service, and date
    // _availableTimes = await _dbService.getAvailableTimes(provider.id, service.id, date);

    // (Temporary mock data for time slots - pretending some are booked)
    await Future.delayed(Duration(milliseconds: 300));
    // Example: Generate slots from 9 AM to 5 PM, every 30 minutes
    List<String> allSlots = [];
    DateTime startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    DateTime endTime = DateTime(date.year, date.month, date.day, 17, 0); // 5:00 PM
    while (startTime.isBefore(endTime)) {
      allSlots.add(DateFormat('h:mm a').format(startTime)); // Format as "9:00 AM"
      startTime = startTime.add(Duration(minutes: 30));
    }

    // Simulate some booked slots based on the date
    if (date.day % 2 == 0) { // Even days have fewer slots
      allSlots.removeRange(2, 5);
      allSlots.remove("1:00 PM");
    } else { // Odd days
      allSlots.remove("11:30 AM");
    }

    _availableTimes = allSlots;
    _isLoading = false;
    notifyListeners();
  }

  // Select a date
  void selectDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      fetchAvailableTimes(date); // Fetch times for the newly selected date
      notifyListeners();
    }
  }

  // Select a time slot
  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  // Proceed to the next step (Booking & Payment)
// (Inside TimeSelectionViewModel)
  void confirmTime(BuildContext context) {
    if (_selectedDate != null && _selectedTime != null) {
      print("Confirming Time: Date=${DateFormat('yyyy-MM-dd').format(_selectedDate!)}, Time=$_selectedTime");
      // --- UPDATE NAVIGATION ---
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingPaymentView(
            provider: provider,      // Pass provider
            service: service,        // Pass service
            selectedDate: _selectedDate!, // Pass selected date
            selectedTime: _selectedTime!, // Pass selected time
          ),
        ),
      );
      // -----------------------
    }
  }
}