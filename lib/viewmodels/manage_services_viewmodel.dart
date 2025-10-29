import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // (عشان موديل الخدمة)

class ManageServicesViewModel extends ChangeNotifier {
  final DbService _dbService;
  final String providerId; // ID المزود اللي بنعدل خدماته

  List<ProviderServiceModel> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers لإضافة خدمة جديدة
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  List<ProviderServiceModel> get services => _services;
  String? get errorMessage => _errorMessage;

  ManageServicesViewModel(this._dbService, this.providerId) {
    // جلب الخدمات الحالية للمزود ده
    fetchServices();
  }

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await _dbService.getServicesForProvider(providerId);
    } catch (e) {
      _errorMessage = "Failed to load services.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة إضافة خدمة جديدة
  Future<void> addService() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || durationController.text.isEmpty) {
      _errorMessage = "Please fill all fields.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // (هنحتاج نضيف دالة جديدة في DbService لإضافة الخدمة)
      await _dbService.addServiceToProvider(
        providerId: providerId,
        serviceName: nameController.text,
        price: priceController.text,
        duration: durationController.text,
      );

      // مسح الحقول بعد الإضافة
      nameController.clear();
      priceController.clear();
      durationController.clear();

      // إعادة تحميل القائمة
      await fetchServices();

    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false; // (fetchServices هتعمل notify)
    }
  }

  // دالة حذف خدمة
  Future<void> deleteService(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // (هنحتاج نضيف دالة جديدة في DbService لحذف الخدمة)
      await _dbService.deleteServiceFromProvider(providerId: providerId, serviceId: serviceId);
      await fetchServices(); // إعادة تحميل القائمة
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false; // (fetchServices هتعمل notify)
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.dispose();
  }
}