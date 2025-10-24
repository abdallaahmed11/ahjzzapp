import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';

// 1. نستخدم "ChangeNotifier" ليخبر الواجهة متى تتحدث
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  // 2. الـ "State" الخاص بهذه الشاشة
  bool _isLoading = false;
  String? _errorMessage;

  // 3. تعريف الـ Controllers الخاصة بالنصوص
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 4. "Getters" للسماح للواجهة بقراءة الحالة (بشكل آمن)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 5. Constructor
  LoginViewModel(this._authService);

  // 6. دالة اللوجيك (تسجيل الدخول)
  Future<bool> login() async {
    // إخطار الواجهة: "ابدأ التحميل"
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // <-- هذا هو الأمر السحري في Provider

    try {
      await _authService.signIn(
        emailController.text,
        passwordController.text,
      );

      // إخطار الواجهة: "توقف عن التحميل"
      _isLoading = false;
      notifyListeners();
      return true; // نجح

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false; // فشل
    }
  }

// (سنضيف دوال التنقل هنا لاحقاً)
}