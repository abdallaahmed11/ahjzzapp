import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
// (سنحتاج خدمة Firestore لحفظ الاسم)
// import 'package:ahjizzzapp/services/db_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService;
  // final DbService _dbService; (سنضيفها لاحقاً)

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SignUpViewModel(this._authService);

  Future<bool> signUp() async {
    // التحقق من تطابق كلمة المرور
    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = "Passwords do not match.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. إنشاء المستخدم في Firebase Auth
      await _authService.signUp(
        emailController.text,
        passwordController.text,
      );

      // 2. TODO: حفظ الاسم في Firestore
      // await _dbService.createUserProfile(
      //   uid: userCredential.user!.uid,
      //   name: nameController.text,
      //   email: emailController.text
      // );

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
}