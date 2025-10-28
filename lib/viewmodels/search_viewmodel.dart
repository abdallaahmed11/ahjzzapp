import 'dart:async'; // لاستخدام Timer
import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class SearchViewModel extends ChangeNotifier {
  final DbService _dbService;

  // --- الحالة (State) ---
  bool _isLoading = false;
  List<ServiceProvider> _results = []; // قائمة النتائج
  String _query = ""; // نص البحث الحالي
  Timer? _debounce; // مؤقت لتقليل عدد مرات البحث أثناء الكتابة

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<ServiceProvider> get results => _results;
  String get query => _query; // لمعرفة ما إذا كان هناك بحث حالي

  // --- Constructor ---
  SearchViewModel(this._dbService);

  // --- الأفعال (Actions) ---

  // دالة تُستدعى كلما تغير النص في شريط البحث
  void onSearchChanged(String newQuery) {
    _query = newQuery; // تحديث نص البحث فوراً

    // إذا كان المؤقت (debounce) شغال، ألغه
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // لو نص البحث بقى فاضي، امسح النتائج علطول
    if (newQuery.isEmpty) {
      _isLoading = false;
      _results = [];
      notifyListeners();
      return;
    }

    // إظهار التحميل فوراً إذا كان النص غير فارغ
    _isLoading = true;
    notifyListeners();

    // بدء مؤقت جديد: انتظر 500 مللي ثانية بعد آخر حرف اتكتب قبل ما تبدأ البحث
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // بعد انتهاء المؤقت، ابدأ البحث الفعلي
      _performSearch(newQuery);
    });
  }

  // دالة البحث الفعلية
  Future<void> _performSearch(String query) async {
    // (نتأكد إن البحث لسه مطلوب ومفضيش)
    if (_query != query || _query.isEmpty) return;

    print("SearchViewModel: Performing search for '$query'");
    try {
      // استدعاء الخدمة لجلب البيانات
      _results = await _dbService.searchProviders(query);

    } catch (e) {
      print("Error in SearchViewModel: $e");
      _results = []; // إرجاع قائمة فارغة عند الخطأ
    } finally {
      // (نتأكد إننا لسه بنعرض نتائج البحث ده ومفيش بحث جديد بدأ)
      if (_query == query) {
        _isLoading = false;
        notifyListeners(); // تحديث الواجهة بالنتائج الجديدة
      }
    }
  }

  // دالة لمسح البحث
  void clearSearch() {
    _query = "";
    _results = [];
    _isLoading = false;
    _debounce?.cancel();
    notifyListeners();
  }

  // تنظيف المؤقت
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}