import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
// import 'package:ahjizzzapp/services/db_service.dart'; // (سنضيفه لاحقاً)

class MyBookingsViewModel extends ChangeNotifier {
  // final DbService _dbService; // (سنستخدمه لجلب البيانات من Firestore)

  bool _isLoading = false;
  List<BookingModel> _allBookings = [];

  bool get isLoading => _isLoading;

  // قوائم مفلترة لكل تاب
  List<BookingModel> get upcomingBookings =>
      _allBookings.where((b) => b.status == BookingStatus.upcoming).toList();

  List<BookingModel> get completedBookings =>
      _allBookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BookingModel> get cancelledBookings =>
      _allBookings.where((b) => b.status == BookingStatus.cancelled).toList();

  // MyBookingsViewModel(this._dbService) { // (الـ Constructor المستقبلي)
  MyBookingsViewModel() { // (Constructor مؤقت)
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    // TODO: استبدل هذا ببيانات حقيقية من Firestore
    // _allBookings = await _dbService.getUserBookings();

    // (بيانات وهمية مؤقتة مطابقة للتصميم)
    await Future.delayed(Duration(seconds: 1)); // محاكاة تحميل
    _allBookings = [
      // Upcoming [cite: 108]
      BookingModel(
          id: '1',
          providerName: "Sam's Barbershop", // [cite: 111]
          serviceName: "Men's Haircut & Beard Trim", // [cite: 112]
          dateTime: DateTime(2025, 10, 23, 14, 0), // Thu, 23 Oct 2:00 PM [cite: 113, 114]
          price: "\$35", // [cite: 115]
          status: BookingStatus.upcoming // [cite: 121] ("confirmed" implies upcoming)
      ),
      BookingModel(
          id: '2',
          providerName: "Elite Auto Wash", // [cite: 116]
          serviceName: "Full Car Detailing", // [cite: 117]
          dateTime: DateTime(2025, 10, 24, 10, 0), // Fri, 24 Oct 10:00 AM [cite: 118, 119]
          price: "\$60", // [cite: 120]
          status: BookingStatus.upcoming // [cite: 124]
      ),
      // Completed [cite: 109, 133]
      BookingModel(
          id: '3',
          providerName: "Sparkle Cleaners", // [cite: 135]
          serviceName: "Deep House Cleaning", // [cite: 136]
          dateTime: DateTime(2025, 10, 20, 9, 0), // Mon, 20 Oct 9:00 AM [cite: 137, 138]
          price: "\$60", // [cite: 139]
          status: BookingStatus.completed
      ),
      BookingModel(
          id: '4',
          providerName: "Premium Cuts Studio", // [cite: 140]
          serviceName: "Premium Styling", // [cite: 141]
          dateTime: DateTime(2025, 10, 19, 15, 0), // Sun, 19 Oct 3:00 PM [cite: 142, 143]
          price: "\$40", // [cite: 144]
          status: BookingStatus.completed
      ),
      // Cancelled [cite: 110, 155]
      BookingModel(
          id: '5',
          providerName: "AutoCare Express", // [cite: 156]
          serviceName: "Car Wash", // [cite: 157]
          dateTime: DateTime(2025, 10, 18, 11, 0), // Sat, 18 Oct 11:00 AM [cite: 158, 159]
          price: "\$35", // [cite: 160]
          status: BookingStatus.cancelled // [cite: 161]
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // (سنضيف دوال Cancel / Reschedule هنا لاحقاً)
  Future<void> cancelBooking(String bookingId) async {
    // TODO: Implement cancellation logic (call DbService)
    print("Cancelling booking $bookingId");
    // Refresh list after cancellation
    await fetchBookings();
  }
}