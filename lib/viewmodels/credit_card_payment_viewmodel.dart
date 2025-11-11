import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// استيراد الموديلات والخدمات
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// (دالة مساعدة لدمج التاريخ والوقت - يمكنك وضعها هنا أو استيرادها)
DateTime combineDateAndTime(DateTime date, String timeString) {
  try {
    final format = DateFormat("h:mm a");
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  } catch(e){
    print("Error parsing time string '$timeString': $e");
    return DateTime(date.year, date.month, date.day);
  }
}

class CreditCardPaymentViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // --- البيانات المستلمة من الشاشة السابقة ---
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final double totalPrice; // السعر الإجمالي
  final String? discountCode; // كود الخصم (إن وجد)

  // --- Controllers لحقول النص ---
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderNameController = TextEditingController();

  // --- الحالة (State) ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  CreditCardPaymentViewModel({
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.totalPrice,
    this.discountCode,
    required DbService dbService,
    required AuthService authService,
  })  : _dbService = dbService,
        _authService = authService;


  // --- الأفعال (Actions) ---

  // دالة "محاكاة" الدفع
  Future<bool> submitPayment() async {
    // 1. التحقق (الوهمي) من صحة البيانات
    if (cardNumberController.text.isEmpty ||
        expiryDateController.text.isEmpty ||
        cvvController.text.isEmpty ||
        cardHolderNameController.text.isEmpty) {
      _errorMessage = "Please fill all card details.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. محاكاة وقت الاتصال بالبنك (ننتظر 3 ثواني)
      await Future.delayed(Duration(seconds: 3));

      // (هنا المفروض نكلم Stripe/Paymob، لكننا سنتجاوزها)
      print("Payment Simulation Successful!");

      // 3. بما أن الدفع "نجح"، قم بإنشاء الحجز في Firestore
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");
      final DateTime bookingDateTime = combineDateAndTime(selectedDate, selectedTime);

      await _dbService.createBooking(
        userId: userId,
        providerId: provider.id,
        providerName: provider.name,
        serviceId: service.id,
        serviceName: service.name,
        dateTime: bookingDateTime,
        price: "\$${totalPrice.toStringAsFixed(2)}", // السعر النهائي
        notes: null, // (يمكن تمرير الملاحظات أيضاً لو أردنا)
        paymentMethod: "online_paid", // <-- تحديد أنه تم الدفع أونلاين
        discountCode: discountCode,
        status: 'upcoming',
      );

      print("Booking Saved to Firestore after successful payment!");
      _isLoading = false;
      notifyListeners();
      return true; // نجح الدفع والحجز

    } catch (e) {
      print("Error submitting payment: $e");
      _isLoading = false;
      _errorMessage = "An error occurred: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false; // فشل الدفع أو الحجز
    }
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    cardHolderNameController.dispose();
    super.dispose();
  }
}