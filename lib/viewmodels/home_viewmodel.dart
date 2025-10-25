import 'package:flutter/material.dart';
// استيراد الخدمات
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart'; // <-- 1. استيراد AuthService
// استيراد كل الموديلات المطلوبة
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService; // <-- 2. إضافة AuthService

  // --- متغيرات الحالة ---
  String _userName = "User"; // قيمة أولية (سيتم تحديثها)
  bool _isLoading = false;
  List<ServiceProvider> _servicesNearYou = [];
  List<QuickCategory> _quickCategories = [];
  List<TopRatedProvider> _topRatedProviders = [];

  // --- Getters ---
  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<ServiceProvider> get servicesNearYou => _servicesNearYou;
  List<QuickCategory> get quickCategories => _quickCategories;
  List<TopRatedProvider> get topRatedProviders => _topRatedProviders;

  // --- Constructor (مُعدل) ---
  // 3. تعديل الـ Constructor ليستقبل AuthService
  HomeViewModel(this._dbService, this._authService) {
    // جلب كل البيانات (بما في ذلك اسم المستخدم) عند بدء التشغيل
    fetchData();
  }

  // --- الأفعال (Actions) ---

  // **** 4. تعديل دالة fetchData لتشمل جلب اسم المستخدم ****
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners(); // إخطار الواجهة بأن التحميل بدأ

    try {
      // جلب بيانات المستخدم أولاً
      final String? userId = _authService.currentUser?.uid;
      String? fetchedName;
      if (userId != null) {
        // جلب الاسم بالتوازي مع باقي البيانات
        fetchedName = await _dbService.getUserName(userId);
      }

      // جلب باقي بيانات الشاشة الرئيسية
      final results = await Future.wait([
        _dbService.getCategories(),
        _dbService.getServicesNearYou(),
        _dbService.getTopRatedProviders(),
      ]);

      // تعيين النتائج لمتغيرات الحالة
      _quickCategories = results[0] as List<QuickCategory>? ?? [];
      _servicesNearYou = results[1] as List<ServiceProvider>? ?? [];
      _topRatedProviders = results[2] as List<TopRatedProvider>? ?? [];
      // تعيين اسم المستخدم (استخدام "User" كقيمة افتراضية إذا فشل الجلب)
      _userName = fetchedName ?? "User";
      print("HomeViewModel: Data fetched successfully.");
      print("HomeViewModel: User name set to: $_userName");

    } catch (e) {
      print("Error fetching home data in ViewModel: $e");
      // (يمكن تعيين رسالة خطأ هنا)
    } finally {
      _isLoading = false;
      notifyListeners(); // إخطار الواجهة بأن التحميل انتهى
    }
  }
}