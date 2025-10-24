import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart'; // سنحتاجها لتسجيل الخروج

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;

  // --- (الحالة) State ---
  String _userName = "Ahmed Hassan"; // (بيانات وهمية مؤقتة)
  String _userEmail = "ahmed.hassan@email.com"; // (بيانات وهمية مؤقتة)
  String _selectedLanguage = "English"; // اللغة الافتراضية
  bool _notificationsEnabled = true; // (مثال لإعداد)

  // --- (Getters) للقراءة الآمنة ---
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;

  ProfileViewModel(this._authService) {
    // TODO: جلب بيانات المستخدم الحقيقية من Firestore عند بدء التشغيل
    // _loadUserProfile();
  }

  // --- (الأفعال) Actions ---

  // دالة تغيير اللغة
  void changeLanguage(String language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      print("Language changed to: $language");
      // TODO: حفظ اللغة الجديدة (مثلاً باستخدام GetStorage أو SharedPreferences)
      // TODO: تحديث لغة التطبيق فعلياً (باستخدام مكتبة localisation)
      notifyListeners(); // إخطار الواجهة بالتغيير
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
    // TODO: Implement actual logout using _authService.signOut()
    // await _authService.signOut();

    // (بعد تسجيل الخروج، يجب إعادة المستخدم لشاشة تسجيل الدخول)
  }

// (دالة وهمية لتحميل بيانات المستخدم)
// Future<void> _loadUserProfile() async { ... }
}