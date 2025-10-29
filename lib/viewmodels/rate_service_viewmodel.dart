import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart';

class RateServiceViewModel extends ChangeNotifier {
  // --- الخدمات المطلوبة ---
  final DbService _dbService;
  final AuthService _authService;

  // --- البيانات المستلمة ---
  final String bookingId;    // ID الحجز
  final String providerId;   // ID مزود الخدمة
  final String providerName; // اسم مزود الخدمة

  // --- الحالة (State) ---
  double _rating = 0.0;
  final reviewController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  RateServiceViewModel({
    required this.bookingId,
    required this.providerId,
    required this.providerName,
    required DbService dbService,
    required AuthService authService,
  })  : _dbService = dbService,
        _authService = authService;
  // -------------------------

  void setRating(double newRating) {
    if (_rating != newRating) {
      _rating = newRating;
      notifyListeners();
    }
  }

  // --- دالة حفظ التقييم (مُحدثة) ---
  Future<bool> submitReview() async {
    if (_rating == 0.0) {
      _errorMessage = "Please select a star rating.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. جلب بيانات المستخدم
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");

      final String userName = await _dbService.getUserName(userId) ?? "Anonymous";

      // 2. استدعاء دالة submitReview (المُحدثة)
      // هذه الدالة الآن تقوم بحفظ التقييم وتحديث حالة الحجز وتحديث متوسط التقييم
      // كل هذا داخل Transaction واحدة.
      await _dbService.submitReview(
        bookingId: bookingId,
        providerId: providerId,
        providerName: providerName,
        userId: userId,
        userName: userName,
        rating: _rating,
        reviewText: reviewController.text.trim(),
      );

      // (لم نعد بحاجة لاستدعاء updateBookingStatus هنا، لأنها تمت في الـ Transaction)

      _isLoading = false;
      notifyListeners();
      return true; // نجح

    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to submit review: ${e.toString().replaceFirst('Exception: ', '')}";
      notifyListeners();
      return false; // فشل
    }
  }
  // ---------------------------------

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}