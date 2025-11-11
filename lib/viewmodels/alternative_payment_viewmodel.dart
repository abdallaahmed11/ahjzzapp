import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// دالة مساعدة للوقت
DateTime combineDateAndTime(DateTime date, String timeString) {
  try {
    final format = DateFormat("h:mm a");
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  } catch(e){
    return DateTime(date.year, date.month, date.day);
  }
}

class AlternativePaymentViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // البيانات المستلمة
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final double totalPrice;
  final String? discountCode;
  final String paymentMethodName; // اسم الطريقة (vodafone_cash, instapay, paypal)

  // Controller واحد للمُعرف (رقم المحفظة / عنوان انستا باي / إيميل باي بال)
  final identifierController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AlternativePaymentViewModel({
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.totalPrice,
    this.discountCode,
    required this.paymentMethodName,
    required DbService dbService,
    required AuthService authService,
  })  : _dbService = dbService,
        _authService = authService;

  Future<bool> submitPayment() async {
    if (identifierController.text.isEmpty) {
      _errorMessage = "Please enter the required details.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. محاكاة وقت المعالجة (2 ثانية)
      await Future.delayed(Duration(seconds: 2));

      // 2. حفظ الحجز في Firestore
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
        notes: "Paid via $paymentMethodName (${identifierController.text})", // حفظ تفاصيل الدفع في الملاحظات
        paymentMethod: paymentMethodName,
        discountCode: discountCode,
        status: 'upcoming',
      );

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _errorMessage = "Payment failed. Please try again.";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    super.dispose();
  }
}