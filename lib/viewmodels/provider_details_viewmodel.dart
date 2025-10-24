import 'package:flutter/material.dart';
// We reuse the ServiceProvider model
import 'package:ahjizzzapp/models/service_provider.dart';
// import 'package:ahjizzzapp/services/db_service.dart'; // To fetch more details

// Example Model for a specific service offered by a provider
class ProviderServiceModel {
  final String id;
  final String name;
  final String price;
  final String duration; // e.g., "30 min"

  ProviderServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });
}

class ProviderDetailsViewModel extends ChangeNotifier {
  // final DbService _dbService; // To fetch real data
  final ServiceProvider provider; // The basic provider info passed from the previous screen

  bool _isLoading = false;
  // List to hold specific services offered by this provider
  List<ProviderServiceModel> _services = [];
  ProviderServiceModel? _selectedService; // Track which service is selected

  bool get isLoading => _isLoading;
  List<ProviderServiceModel> get services => _services;
  ProviderServiceModel? get selectedService => _selectedService;

  // ProviderDetailsViewModel(this._dbService, this.provider) { // Future constructor
  ProviderDetailsViewModel(this.provider) { // Temporary constructor
    fetchProviderServices();
  }

  Future<void> fetchProviderServices() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Replace with real data fetching from Firestore based on provider.id
    // _services = await _dbService.getServicesForProvider(provider.id);

    // (Temporary mock data for services offered by "Sam's Barbershop")
    await Future.delayed(Duration(milliseconds: 500));
    _services = [
      ProviderServiceModel(id: 's1', name: "Men's Haircut", price: "\$25", duration: "30 min"),
      ProviderServiceModel(id: 's2', name: "Beard Trim", price: "\$15", duration: "15 min"),
      ProviderServiceModel(id: 's3', name: "Haircut & Beard", price: "\$35", duration: "45 min"),
      ProviderServiceModel(id: 's4', name: "Kids Haircut", price: "\$20", duration: "25 min"),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Function to select a service
  void selectService(ProviderServiceModel service) {
    _selectedService = service;
    notifyListeners(); // Update UI to show selection/enable button
  }

  // Function to proceed to the next step (Time Selection)
  void proceedToBooking(BuildContext context) {
    if (_selectedService != null) {
      print("Proceeding to book: ${provider.name} - ${_selectedService!.name}");
      // TODO: Navigate to Time Selection Screen, passing provider and selected service
      // Navigator.of(context).pushNamed('/time-selection', arguments: {
      //   'provider': provider,
      //   'service': _selectedService,
      // });
    }
  }
}