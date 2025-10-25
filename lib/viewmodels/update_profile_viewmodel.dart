import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class UpdateProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DbService _dbService;

  // --- Controllers لحقول النص ---
  final nameController = TextEditingController();
  final phoneController = TextEditingController(); // <-- إضافة Controller للهاتف
  final cityController = TextEditingController();  // <-- إضافة Controller للمدينة
  final bioController = TextEditingController();   // <-- إضافة Controller للنبذة

  // --- الحالة (State) ---
  bool _isLoading = true; // (لجلب البيانات أول مرة)
  bool _isSaving = false; // (لزر الحفظ)
  String? _errorMessage;
  String _userEmail = ""; // لعرض الإيميل (للقراءة فقط)

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get userEmail => _userEmail; // Getter للإيميل

  UpdateProfileViewModel(this._authService, this._dbService) {
    // تحميل البيانات الحالية للمستخدم عند فتح الشاشة
    loadCurrentUserData();
  }

  // --- دالة جلب البيانات (مُحدثة) ---
  Future<void> loadCurrentUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");

      // جلب الإيميل من Auth
      _userEmail = _authService.currentUser?.email ?? "No Email";

      // جلب باقي بيانات البروفايل من Firestore
      final Map<String, dynamic>? userProfile = await _dbService.getUserProfile(userId);

      if (userProfile != null) {
        nameController.text = userProfile['name'] ?? ''; // ملء الاسم
        phoneController.text = userProfile['phone'] ?? ''; // ملء الهاتف
        cityController.text = userProfile['city'] ?? '';   // ملء المدينة
        bioController.text = userProfile['bio'] ?? '';     // ملء النبذة
      }

    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // **********************************

  // --- دالة حفظ التغييرات (مُحدثة) ---
  Future<bool> saveChanges() async {
    if (nameController.text.trim().isEmpty) {
      _errorMessage = "Name cannot be empty.";
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");

      // استدعاء دالة التحديث في DbService مع تمرير كل البيانات
      await _dbService.updateUserProfile(
        userId, // <-- تمرير الـ UID كـ positional argument
        name: nameController.text.trim(),
        phone: phoneController.text.trim(), // <-- تمرير الهاتف
        city: cityController.text.trim(),   // <-- تمرير المدينة
        bio: bioController.text.trim(),     // <-- تمرير النبذة
      );

      _isSaving = false;
      notifyListeners();
      return true; // نجح الحفظ

    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false; // فشل الحفظ
    }
  }
  // **********************************

  // تنظيف كل الـ Controllers
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }
}