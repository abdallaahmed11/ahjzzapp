import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DbService _dbService;

  // --- الحالة (State) ---
  String _userName = "Loading...";
  String _userEmail = "";
  String _selectedLanguage = "English";
  bool _notificationsEnabled = true;
  bool _isLoadingProfile = false; // (لإدارة التحميل)

  // --- Getters ---
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoadingProfile => _isLoadingProfile; // (اختياري)

  // --- Constructor ---
  ProfileViewModel(this._authService, this._dbService) {
    // جلب بيانات المستخدم عند بدء التشغيل
    loadUserProfile();
  }

  // --- الأفعال (Actions) ---

  // **** دالة جلب بيانات المستخدم (أصبحت عامة) ****
  Future<void> loadUserProfile() async {
    _isLoadingProfile = true;
    notifyListeners(); // إظهار التحميل

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // جلب الاسم من DbService
        _userName = await _dbService.getUserName(user.uid) ?? "User";
        // جلب الإيميل
        _userEmail = user.email ?? "";
      } else {
        _userName = "Guest";
        _userEmail = "";
      }
    } catch (e) {
      print("Error loading user profile in ViewModel: $e");
      _userName = "Error";
      _userEmail = "";
    } finally {
      _isLoadingProfile = false;
      notifyListeners(); // تحديث الواجهة بالبيانات الجديدة
    }
  }
  // **********************************

  // دالة تغيير اللغة
  void changeLanguage(String language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      print("Language changed to: $language");
      // TODO: حفظ اللغة الجديدة وتحديث لغة التطبيق
      notifyListeners();
    }
  }

  // دالة تفعيل/تعطيل الإشعارات
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    print("Notifications set to: $value");
    // TODO: حفظ الإعداد الجديد
    notifyListeners();
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    print("Logging out...");
    try {
      await _authService.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}