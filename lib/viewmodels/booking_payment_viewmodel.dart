import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// استيراد الموديلات
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/models/discount_model.dart'; // <-- استيراد موديل الخصم
// استيراد الخدمات
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

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

  // البيانات المستلمة
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  // --- الحالة (State) ---
  final notesController = TextEditingController();
  final discountController = TextEditingController(); // Controller لكود الخصم
  PaymentMethod _selectedPaymentMethod = PaymentMethod.payOnArrival;
  bool _isLoading = false; // (للتحميل العام زر "Confirm")
  String? _errorMessage;

  // **** متغيرات جديدة للخصم ****
  DiscountModel? _appliedDiscount; // لحفظ الخصم المطبق
  bool _isVerifyingDiscount = false; // (لإظهار تحميل على زر "Apply")
  String? _discountMessage; // (لإظهار رسالة "تم تطبيق الخصم" أو "كود خاطئ")
  // *******************************

  // --- Getters ---
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(selectedDate);
  String get formattedTime => selectedTime;

  // **** Getters جديدة للخصم ****
  DiscountModel? get appliedDiscount => _appliedDiscount;
  bool get isVerifyingDiscount => _isVerifyingDiscount;
  String? get discountMessage => _discountMessage;
  // ******************************

  // --- Getters لحساب السعر ---
  double get originalPrice {
    // تحويل السعر من نص (مثل "$25") إلى رقم
    try {
      // إزالة علامة الدولار وأي مسافات
      return double.parse(service.price.replaceAll(r'$', '').trim());
    } catch (e) {
      print("Error parsing service price: ${service.price}");
      return 0.0;
    }
  }

  double get discountAmount {
    if (_appliedDiscount != null) {
      // حساب قيمة الخصم
      return originalPrice * (_appliedDiscount!.discountPercentage / 100.0);
    }
    return 0.0; // لا يوجد خصم
  }

  double get totalPrice {
    // السعر النهائي بعد الخصم
    return originalPrice - discountAmount;
  }
  // ***************************


  // --- Constructor ---
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

  // **** دالة جديدة للتحقق من كود الخصم ****
  Future<void> validateDiscountCode() async {
    // التأكد من أن المستخدم كتب كود
    if (discountController.text.trim().isEmpty) {
      _discountMessage = "Please enter a code.";
      _appliedDiscount = null; // إزالة أي خصم قديم
      notifyListeners();
      return;
    }

    _isVerifyingDiscount = true;
    _discountMessage = null;
    notifyListeners(); // إظهار مؤشر التحميل على زر "Apply"

    try {
      // (يفضل توحيد حالة الأحرف)
      final code = discountController.text.trim().toUpperCase();
      final discount = await _dbService.validateDiscountCode(code);

      if (discount != null && discount.isActive) {
        // إذا الكود صحيح وفعال
        _appliedDiscount = discount;
        _discountMessage = "${discount.discountPercentage.toInt()}% discount applied!";
      } else {
        // إذا الكود خاطئ أو غير فعال
        _appliedDiscount = null;
        _discountMessage = "This code is invalid or has expired.";
      }
    } catch (e) {
      _appliedDiscount = null;
      _discountMessage = "Error validating code. Try again.";
    } finally {
      _isVerifyingDiscount = false;
      notifyListeners(); // إخفاء التحميل وتحديث الواجهة بالسعر الجديد
    }
  }
  // ****************************************

  // **** تعديل دالة confirmBooking ****
  Future<bool> confirmBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");
      final DateTime bookingDateTime = combineDateAndTime(selectedDate, selectedTime);

      // (استدعاء DbService مع تمرير السعر النهائي وكود الخصم المطبق)
      await _dbService.createBooking(
        userId: userId,
        providerId: provider.id,
        providerName: provider.name,
        serviceId: service.id,
        serviceName: service.name,
        dateTime: bookingDateTime,
        // (يمكنك حفظ السعر الأصلي والسعر بعد الخصم، أو السعر النهائي فقط)
        price: "\$${totalPrice.toStringAsFixed(2)}", // حفظ السعر النهائي كنص
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        paymentMethod: _selectedPaymentMethod.name,
        // حفظ الكود الذي تم استخدامه
        discountCode: _appliedDiscount?.id, // (نحفظ ID الخصم إذا تم تطبيقه)
        status: 'upcoming',
      );

      print("Booking Saved to Firestore!");
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
  // **********************************

  @override
  void dispose() {
    notesController.dispose();
    discountController.dispose();
    super.dispose();
  }
}