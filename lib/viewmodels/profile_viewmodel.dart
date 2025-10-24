import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // Import DbService

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DbService _dbService; // Add DbService

  // State
  String _userName = "Loading..."; // Initial value
  String _userEmail = "";
  String _selectedLanguage = "English";
  bool _notificationsEnabled = true;

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;

  // Constructor requires services
  ProfileViewModel(this._authService, this._dbService) {
    _loadUserProfile(); // Load profile data on initialization
  }

  // Actions

  // Load user name from DbService and email from AuthService
  Future<void> _loadUserProfile() async {
    _userName = "Loading..."; // Show loading state briefly
    _userEmail = "";
    notifyListeners(); // Update UI immediately

    try {
      final user = _authService.currentUser; // Get current auth user
      if (user != null) {
        // Fetch name from Firestore using DbService
        _userName = await _dbService.getUserName(user.uid) ?? "User"; // Default if name not found
        // Get email directly from auth user object
        _userEmail = user.email ?? "No Email"; // Default if email not found
        notifyListeners(); // Update UI with fetched data
      } else {
        // Handle case where user is somehow null (shouldn't happen if routed correctly)
        _userName = "Guest";
        _userEmail = "";
        notifyListeners();
      }
    } catch (e) {
      print("Error loading user profile in ViewModel: $e");
      _userName = "Error"; // Indicate error in UI
      _userEmail = "";
      notifyListeners();
    }
  }

  // Change language selection
  void changeLanguage(String language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      print("Language changed to: $language");
      // TODO: Save preference and update app locale
      notifyListeners();
    }
  }

  // Toggle notification preference
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    print("Notifications set to: $value");
    // TODO: Save preference
    notifyListeners();
  }

  // Sign out using AuthService
  Future<void> logout() async {
    print("Logging out...");
    try {
      await _authService.signOut(); // Call the actual sign out method
      print("User signed out successfully.");
      // Navigation back to login screen should be handled by an auth state listener (see next step)
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show error to user via Snackbar
    }
  }
}