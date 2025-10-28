import 'package:flutter/material.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // --- متغيرات الحالة ---
  String _userName = "User";
  bool _isLoading = false;
  List<ServiceProvider> _servicesNearYou = [];
  List<QuickCategory> _quickCategories = [];
  List<TopRatedProvider> _topRatedProviders = [];

  // **** 1. إضافة متغيرات المدينة ****
  String _selectedCity = "Cairo"; // المدينة الافتراضية
  final List<String> _availableCities = ["Cairo", "Alexandria", "Giza"]; // قائمة وهمية مؤقتة
  // ******************************

  // --- Getters ---
  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<ServiceProvider> get servicesNearYou => _servicesNearYou;
  List<QuickCategory> get quickCategories => _quickCategories;
  List<TopRatedProvider> get topRatedProviders => _topRatedProviders;

  // **** 2. Getters للمدينة ****
  String get selectedCity => _selectedCity;
  List<String> get availableCities => _availableCities;
  // ***************************

  // --- Constructor ---
  HomeViewModel(this._dbService, this._authService) {
    fetchData(); // جلب البيانات عند بدء التشغيل
  }

  // --- الأفعال (Actions) ---

  // **** 3. تعديل دالة fetchData لتمرير المدينة ****
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // جلب بيانات المستخدم
      final String? userId = _authService.currentUser?.uid;
      String? fetchedName;
      if (userId != null) {
        fetchedName = await _dbService.getUserName(userId);
      }

      // جلب باقي البيانات بناءً على المدينة المختارة
      final results = await Future.wait([
        _dbService.getCategories(),
        // تمرير المدينة المختارة للدوال
        _dbService.getServicesNearYou(city: _selectedCity),
        _dbService.getTopRatedProviders(city: _selectedCity),
      ]);

      // تعيين النتائج
      _quickCategories = results[0] as List<QuickCategory>? ?? [];
      _servicesNearYou = results[1] as List<ServiceProvider>? ?? [];
      _topRatedProviders = results[2] as List<TopRatedProvider>? ?? [];
      _userName = fetchedName ?? "User";

      print("HomeViewModel: Data fetched for city: $_selectedCity");
      print("HomeViewModel: Found ${_topRatedProviders.length} top rated providers.");

    } catch (e) {
      print("Error fetching home data in ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // *******************************************

  // **** 4. دالة جديدة لتغيير المدينة ****
  void changeCity(String newCity) {
    if (_selectedCity != newCity) {
      _selectedCity = newCity;
      print("HomeViewModel: City changed to $_selectedCity");
      notifyListeners(); // (اختياري: لتحديث الواجهة بالاسم الجديد فوراً)
      fetchData(); // <-- إعادة جلب كل البيانات بناءً على المدينة الجديدة
    }
  }
// ************************************
}