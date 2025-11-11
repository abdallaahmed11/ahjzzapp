import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// استيراد الموديلات
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/models/discount_model.dart';
// استيراد الخدمات
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
// (لم نعد بحاجة لاستيراد CreditCardPaymentView)

// (دالة combineDateAndTime المساعدة كما هي)
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

enum PaymentMethod { payOnArrival, payOnline }

class BookingPaymentViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // (البيانات المستلمة كما هي)
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  // (الحالة والـ Controllers كما هي)
  final notesController = TextEditingController();
  final discountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.payOnArrival;
  bool _isLoading = false;
  String? _errorMessage;
  DiscountModel? _appliedDiscount;
  bool _isVerifyingDiscount = false;
  String? _discountMessage;

  // (Getters كما هي)
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(selectedDate);
  String get formattedTime => selectedTime;
  DiscountModel? get appliedDiscount => _appliedDiscount;
  bool get isVerifyingDiscount => _isVerifyingDiscount;
  String? get discountMessage => _discountMessage;
  double get originalPrice {
    try {
      return double.parse(service.price.replaceAll(r'$', '').trim());
    } catch (e) {
      print("Error parsing service price: ${service.price}");
      return 0.0;
    }
  }
  double get discountAmount {
    if (_appliedDiscount != null) {
      return originalPrice * (_appliedDiscount!.discountPercentage / 100.0);
    }
    return 0.0;
  }
  double get totalPrice {
    return originalPrice - discountAmount;
  }

  // (Constructor كما هو)
  BookingPaymentViewModel(this._dbService, this._authService, {
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  });

  // (دالة selectPaymentMethod كما هي)
  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  // (دالة validateDiscountCode كما هي)
  Future<void> validateDiscountCode() async {
    if (discountController.text.trim().isEmpty) {
      _discountMessage = "Please enter a code.";
      _appliedDiscount = null;
      notifyListeners();
      return;
    }
    _isVerifyingDiscount = true;
    _discountMessage = null;
    notifyListeners();
    try {
      final code = discountController.text.trim().toUpperCase();
      final discount = await _dbService.validateDiscountCode(code);
      if (discount != null && discount.isActive) {
        _appliedDiscount = discount;
        _discountMessage = "${discount.discountPercentage.toInt()}% discount applied!";
      } else {
        _appliedDiscount = null;
        _discountMessage = "This code is invalid or has expired.";
      }
    } catch (e) {
      _appliedDiscount = null;
      _discountMessage = "Error validating code. Try again.";
    } finally {
      _isVerifyingDiscount = false;
      notifyListeners();
    }
  }

  // (دالة "الدفع عند الوصول")
  Future<bool> submitPayOnArrivalBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
        price: "\$${totalPrice.toStringAsFixed(2)}",
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        paymentMethod: "pay_on_arrival", // <-- تحديد طريقة الدفع
        discountCode: _appliedDiscount?.id,
        status: 'upcoming',
      );

      print("Booking Saved to Firestore (Pay on Arrival)!");
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      print("Error confirming booking: $e");
      _isLoading = false;
      _errorMessage = "An error occurred: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false;
    }
  }

  // **** دالة جديدة: "محاكاة الدفع الأونلاين" ****
  // (هذه الدالة ستقوم بالحجز بعد محاكاة الدفع)
  Future<bool> submitOnlinePaymentSimulation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // إظهار التحميل (سيغطي الشاشة كلها)

    try {
      // 1. محاكاة وقت الاتصال بالبنك (ننتظر ثانيتين)
      await Future.delayed(Duration(seconds: 2));
      print("Payment Simulation Successful!");

      // 2. بما أن الدفع "نجح"، قم بإنشاء الحجز في Firestore
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
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        paymentMethod: "online_paid", // <-- تحديد أنه تم الدفع أونلاين
        discountCode: _appliedDiscount?.id,
        status: 'upcoming',
      );

      print("Booking Saved to Firestore after successful payment!");
      _isLoading = false;
      notifyListeners();
      return true; // نجح الدفع والحجز

    } catch (e) {
      print("Error submitting online payment: $e");
      _isLoading = false;
      _errorMessage = "An error occurred: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false; // فشل الدفع أو الحجز
    }
  }
  // **********************************

  @override
  void dispose() {
    notesController.dispose();
    discountController.dispose();
    super.dispose();
  }
}