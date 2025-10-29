import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart';

class AdminViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // --- الحالة (State) ---
  bool _isAdmin = false;
  String _userRole = 'user'; // 'admin' or 'user'
  bool _isLoadingRole = true; // لحالة التحميل الأولي

  // --- Getters ---
  bool get isAdmin => _isAdmin;
  String get userRole => _userRole;
  bool get isLoadingRole => _isLoadingRole;

  AdminViewModel(this._dbService, this._authService) {
    // جلب دور المستخدم عند إنشاء الـ ViewModel
    checkUserRole();
  }

  // دالة التحقق من دور المستخدم (لابد أن تكون عامة)
  Future<void> checkUserRole() async {
    _isLoadingRole = true;
    notifyListeners();

    final userId = _authService.currentUser?.uid;

    if (userId != null) {
      // جلب الدور من Firestore
      final role = await _dbService.getUserRole(userId);
      _userRole = role ?? 'user';
      _isAdmin = (_userRole == 'admin');
    } else {
      _userRole = 'guest';
      _isAdmin = false;
    }

    _isLoadingRole = false;
    notifyListeners();
    print("AdminViewModel: User Role is: $_userRole (Admin: $_isAdmin)");
  }
}