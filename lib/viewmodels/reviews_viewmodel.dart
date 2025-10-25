import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/review_model.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart';

class ReviewsViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // --- الحالة (State) ---
  bool _isLoading = false;
  List<ReviewModel> _userReviews = []; // قائمة التقييمات الخاصة بالمستخدم
  String? _errorMessage;

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<ReviewModel> get userReviews => _userReviews;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  ReviewsViewModel(this._dbService, this._authService) {
    // جلب تقييمات المستخدم عند بدء التشغيل
    fetchUserReviews();
  }

  // --- الأفعال (Actions) ---

  // دالة جلب تقييمات المستخدم
  Future<void> fetchUserReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // إظهار التحميل

    try {
      // 1. جلب User ID
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      // 2. استدعاء الدالة الجديدة من DbService
      _userReviews = await _dbService.getReviewsByUser(userId);

    } catch (e) {
      print("Error fetching user reviews: $e");
      _errorMessage = "Could not load your reviews.";
      _userReviews = []; // تفريغ القائمة عند الخطأ
    } finally {
      _isLoading = false;
      notifyListeners(); // إخفاء التحميل وتحديث الواجهة
    }
  }

// TODO: إضافة دالة لحذف التقييم (اختياري)
// Future<void> deleteReview(String reviewId) async { ... }
}