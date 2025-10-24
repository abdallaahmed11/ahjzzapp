import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // Import DbService

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DbService _dbService; // Add DbService

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor now requires both services
  SignUpViewModel(this._authService, this._dbService);

  Future<bool> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = "Passwords do not match.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 2. Save user profile to Firestore using DbService
      if (userCredential.user != null) {
        await _dbService.createUserProfile( // Call DbService method
          uid: userCredential.user!.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        );
      } else {
        throw Exception("User creation failed, UID is null after signup.");
      }

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Clean error message
      notifyListeners();
      return false; // Failure
    }
  }

  // Navigation (can stay the same)
  void goToLogin(BuildContext context){
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}