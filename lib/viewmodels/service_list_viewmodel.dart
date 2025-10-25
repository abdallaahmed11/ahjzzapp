import 'package:flutter/material.dart';
// Import models and services
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // Import DbService

class ServiceListViewModel extends ChangeNotifier {
  // Service for database interactions
  final DbService _dbService;
  // Category name is used for fetching and display
  final String categoryName;
  // Category ID might be needed for other operations later
  // final String categoryId;

  // --- State Variables ---
  bool _isLoading = false;
  List<ServiceProvider> _providers = [];
  String _sortBy = "Top Rated"; // Default sort option
  String? _errorMessage; // To hold potential error messages

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<ServiceProvider> get providers => _providers;
  String get sortBy => _sortBy;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // Requires DbService and the category name
  ServiceListViewModel(this._dbService, this.categoryName) {
    // Fetch providers for this category when the ViewModel is created
    fetchProviders();
  }

  // --- Actions ---

  // Fetches providers from DbService based on the current category and sort option
  Future<void> fetchProviders() async {
    _isLoading = true;
    _errorMessage = null; // Clear previous error
    notifyListeners(); // Notify UI that loading started

    try {
      // Call the DbService method to get providers for the specific category
      _providers = await _dbService.getProvidersByCategory(
        categoryName,   // Pass the category name for filtering in Firestore
        sortBy: _sortBy, // Pass the current sort option
        // limit: 10,  // Optionally limit the number fetched
      );
      print("ServiceListViewModel: Fetched ${_providers.length} providers for $categoryName");

    } catch (e) {
      print("Error fetching providers in ViewModel: $e");
      _errorMessage = "Could not load providers. Please try again."; // Set error message
      _providers = []; // Ensure list is empty on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading finished
    }
  }

  // Called when the user selects a different sort option from the UI
  void changeSortOption(String newSortOption) {
    // Only refetch if the sort option actually changed
    if (_sortBy != newSortOption) {
      _sortBy = newSortOption;
      print("ServiceListViewModel: Changing sort option to: $_sortBy");
      // Refetch data using the new sort option
      fetchProviders();
      // No need for notifyListeners() here, fetchProviders will call it
    }
  }
}