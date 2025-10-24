import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DbService _dbService;

  String _userName = "Ahmed"; // [cite: 31] (سنجلبه من Firestore لاحقاً)
  bool _isLoading = false;

  List<ServiceProvider> _servicesNearYou = [];
  List<QuickCategory> _quickCategories = [];
  List<TopRatedProvider> _topRatedProviders = [];

  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<ServiceProvider> get servicesNearYou => _servicesNearYou;
  List<QuickCategory> get quickCategories => _quickCategories;
  List<TopRatedProvider> get topRatedProviders => _topRatedProviders;

  // HomeViewModel(this._dbService) {
  HomeViewModel(this._dbService) { // <-- تعديل الـ Constructor
    fetchData();
  }

  // (داخل HomeViewModel)
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try { // استخدام try-catch لمعالجة الأخطاء المحتملة
      // --- جلب الفئات الحقيقية (أو الوهمية حالياً) من DbService ---
      _quickCategories = await _dbService.getCategories();
      // -----------------------------------------------------

      // TODO: جلب باقي البيانات (Services Near You, Top Rated) من DbService لاحقاً
      // _servicesNearYou = await _dbService.getServicesNearYou();
      // _topRatedProviders = await _dbService.getTopRated();

      // --- (إزالة أو تعليق البيانات الوهمية القديمة الخاصة بالفئات) ---
      // _quickCategories = [ ... ]; // <-- هذا السطر يتم إلغاؤه
      // -------------------------------------------------------

      // (البيانات الوهمية للأقسام الأخرى تظل مؤقتاً)
      _servicesNearYou = [
        ServiceProvider(id: "1", name: "Sam's Barbershop", image: "...", rating: 4.8, price: "\$25", distance: "1.2 km away"),
        ServiceProvider(id: "2", name: "Elite Auto Wash", image: "...", rating: 4.9, price: "\$40", distance: "0.8 km away"),
      ];
      _topRatedProviders = [
        TopRatedProvider(id: "1", name: "Premium Cuts Studio", rating: 4.9, reviews: 234, category: "Barbershop", price: "\$30"),
        TopRatedProvider(id: "2", name: "Crystal Clean Pro", rating: 4.8, reviews: 187, category: "House Cleaning", price: "\$75"),
        TopRatedProvider(id: "3", name: "AutoCare Express", rating: 4.7, reviews: 156, category: "Car Wash", price: "\$35"),
      ];
      // -------------------------------------------------------

    } catch (e) {
      print("Error fetching home data: $e");
      // (يمكن عرض رسالة خطأ للمستخدم هنا)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}