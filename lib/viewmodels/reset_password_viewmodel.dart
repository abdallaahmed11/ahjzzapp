import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;

  final emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get success => _success; // لإظهار رسالة النجاح

  ResetPasswordViewModel(this._authService);

  Future<void> sendResetLink() async {
    _isLoading = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(emailController.text);
      _isLoading = false;
      _success = true; // نجح
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _success = false; // فشل
      notifyListeners();
    }
  }
}