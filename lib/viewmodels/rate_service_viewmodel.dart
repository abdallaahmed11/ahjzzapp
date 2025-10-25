import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';     // استيراد خدمة قاعدة البيانات
import 'package:ahjizzzapp/services/auth_service.dart';    // استيراد خدمة المصادقة

class RateServiceViewModel extends ChangeNotifier {
  // --- الخدمات المطلوبة ---
  final DbService _dbService;
  final AuthService _authService;

  // --- البيانات المستلمة ---
  final String bookingId;    // ID الحجز
  final String providerId;   // ID مزود الخدمة
  final String providerName; // اسم مزود الخدمة

  // --- الحالة (State) ---
  double _rating = 0.0; // التقييم بالنجوم
  final reviewController = TextEditingController(); // للنص
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // يستقبل كل الخدمات والبيانات المطلوبة
  RateServiceViewModel({
    required this.bookingId,
    required this.providerId,
    required this.providerName,
    required DbService dbService,
    required AuthService authService,
  })  : _dbService = dbService,
        _authService = authService;
  // -------------------------

  // دالة لتحديث النجوم عند الضغط
  void setRating(double newRating) {
    if (_rating != newRating) {
      _rating = newRating;
      notifyListeners();
    }
  }

  // --- دالة حفظ التقييم (مُحدثة) ---
  Future<bool> submitReview() async {
    // التحقق من أن المستخدم اختار تقييم
    if (_rating == 0.0) {
      _errorMessage = "Please select a star rating.";
      notifyListeners();
      return false; // فشل
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // إظهار التحميل

    try {
      // 1. جلب بيانات المستخدم الحالي
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");

      // جلب اسم المستخدم من Firestore (أو يمكنك استخدام الإيميل كحل بديل)
      final String userName = await _dbService.getUserName(userId) ?? "Anonymous";

      // 2. استدعاء DbService لحفظ التقييم في مجموعة 'reviews'
      await _dbService.submitReview(
        bookingId: bookingId,
        providerId: providerId,
        providerName: providerName,
        userId: userId,
        userName: userName,
        rating: _rating,
        reviewText: reviewController.text.trim(),
      );

      // 3. تحديث حالة الحجز الأصلي إلى "rated"
      // (حتى لا يظهر زر "Rate Service" مرة أخرى)
      await _dbService.updateBookingStatus(bookingId, "rated");

      _isLoading = false;
      notifyListeners(); // إخفاء التحميل
      return true; // نجح

    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to submit review: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false; // فشل
    }
  }
  // ---------------------------------

  // تنظيف الـ Controller
  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}