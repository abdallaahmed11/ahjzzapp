import 'package:flutter/material.dart';
// (We'll reuse the ServiceProvider model from Home)
import 'package:ahjizzzapp/models/service_provider.dart';
// import 'package:ahjizzzapp/services/db_service.dart'; // To fetch data

class ServiceListViewModel extends ChangeNotifier {
  // final DbService _dbService; // To fetch real data
  final String categoryId; // ID of the category selected (e.g., "barbershop_id")
  final String categoryName; // Name to display in AppBar (e.g., "Barbershops")

  bool _isLoading = false;
  List<ServiceProvider> _providers = [];
  String _sortBy = "Top Rated"; // Default sort option

  bool get isLoading => _isLoading;
  List<ServiceProvider> get providers => _providers;
  String get sortBy => _sortBy;

  // ServiceListViewModel(this._dbService, this.categoryId, this.categoryName) { // Future constructor
  ServiceListViewModel(this.categoryId, this.categoryName) { // Temporary constructor
    fetchProviders();
  }

  Future<void> fetchProviders() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Replace with real data fetching from Firestore based on categoryId and sortBy
    // _providers = await _dbService.getProvidersByCategory(categoryId, sortBy: _sortBy);

    // (Temporary mock data - Assuming we clicked "Barbershop")
    await Future.delayed(Duration(seconds: 1));
    _providers = [
      ServiceProvider(id: "1", name: "Sam's Barbershop", image: "https://images.unsplash.com/photo-1759134198561-e2041049419c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBiYXJiZXJzaG9wJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzYxMTM3MzM1fDA&ixlib.rb.js?w=600", rating: 4.8, price: "\$25", distance: "1.2 km"),
      ServiceProvider(id: "4", name: "Premium Cuts Studio", image: "https://images.unsplash.com/photo-1634118968948-e8a2a11c0c66?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxiYXJiZXJzaG9wfGVufDF8fHx8MTc2MjI0NzAyNHww&ixlib=rb-4.js?w=600", rating: 4.9, price: "\$30", distance: "0.5 km"),
      ServiceProvider(id: "5", name: "The Modern Gent", image: "https://images.unsplash.com/photo-159811099-C62461823795?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwzfHxiYXJiZXJzaG9wfGVufDF8fHx8MTc2MjI0NzAyNHww&ixlib=rb-4.js?w=600", rating: 4.6, price: "\$20", distance: "2.5 km"),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Function to handle sorting change
  void changeSortOption(String newSortOption) {
    if (_sortBy != newSortOption) {
      _sortBy = newSortOption;
      print("Sorting by: $_sortBy");
      // Refetch data with the new sort option
      fetchProviders();
      notifyListeners();
    }
  }
}