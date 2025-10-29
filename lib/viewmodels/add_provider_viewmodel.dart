import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class AddProviderViewModel extends ChangeNotifier {
  final DbService _dbService;

  // Controllers لكل الحقول
  final nameController = TextEditingController();
  final categoryController = TextEditingController(); // (يمكن تحويله لـ Dropdown لاحقًا)
  final cityController = TextEditingController();
  final imageUrlController = TextEditingController();
  final priceIndicatorController = TextEditingController();
  final distanceController = TextEditingController();

  // الحالة
  bool _isSaving = false;
  String? _errorMessage;

  // Getters
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  AddProviderViewModel(this._dbService);

  // دالة لحفظ مزود الخدمة الجديد
  Future<bool> saveProvider() async {
    // (يمكن إضافة تحقق من الحقول هنا)
    if (nameController.text.isEmpty || categoryController.text.isEmpty || cityController.text.isEmpty) {
      _errorMessage = "Name, Category, and City are required.";
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.addServiceProvider(
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        city: cityController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        priceIndicator: priceIndicatorController.text.trim(),
        distance: distanceController.text.trim(),
        // (يمكن إضافة باقي الحقول بقيم افتراضية أو حقول في الفورم)
      );

      _isSaving = false;
      notifyListeners();
      return true; // نجح الحفظ

    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false; // فشل الحفظ
    }
  }

  // تنظيف الـ Controllers
  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    cityController.dispose();
    imageUrlController.dispose();
    priceIndicatorController.dispose();
    distanceController.dispose();
    super.dispose();
  }
}