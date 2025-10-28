import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. استيراد المكتبة

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DbService _dbService;

  // --- الحالة (State) ---
  String _userName = "Loading...";
  String _userEmail = "";
  // (مبقناش محتاجين المتغير ده، لأن المكتبة هي اللي هتحفظ اللغة)
  // String _selectedLanguage = "English";
  bool _notificationsEnabled = true;
  bool _isLoadingProfile = false;

  // --- Getters ---
  String get userName => _userName;
  String get userEmail => _userEmail;
  // (مبقناش محتاجين الـ getter ده)
  // String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoadingProfile => _isLoadingProfile;

  // --- Constructor ---
  ProfileViewModel(this._authService, this._dbService) {
    loadUserProfile();
  }

  // --- الأفعال (Actions) ---

  // (دالة loadUserProfile كما هي)
  Future<void> loadUserProfile() async {
    _isLoadingProfile = true;
    notifyListeners();
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userName = await _dbService.getUserName(user.uid) ?? "User";
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
      notifyListeners();
    }
  }

  // **** 2. تعديل دالة تغيير اللغة ****
  // (الدالة دي هتحتاج BuildContext عشان توصل لـ EasyLocalization)
  void changeLanguage(BuildContext context, String languageCode) {
    // (languageCode هيكون 'en' أو 'ar')
    Locale newLocale = Locale(languageCode);

    // استخدام الدالة المدمجة في المكتبة لتغيير اللغة
    context.setLocale(newLocale);

    print("Language changed to: $languageCode");

    // (المكتبة بتعمل notifyListeners لوحدها وبتعيد بناء الواجهة)
    // (مش محتاجين notifyListeners() هنا)
  }
  // **********************************

  // (دالة toggleNotifications كما هي)
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    print("Notifications set to: $value");
    notifyListeners();
  }

  // (دالة logout كما هي)
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