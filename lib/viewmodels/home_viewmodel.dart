import 'package:flutter/material.dart';
// استيراد الخدمة المطلوبة للتفاعل مع Firestore
import 'package:ahjizzzapp/services/db_service.dart';
// استيراد كل الموديلات المطلوبة
import 'package:ahjizzzapp/models/quick_category.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';

class HomeViewModel extends ChangeNotifier {
  // الخدمة للتفاعل مع Firestore
  final DbService _dbService;

  // --- متغيرات الحالة ---
  // اسم المستخدم (سيتم جلبه لاحقاً)
  String _userName = "User"; // اسم افتراضي
  // مؤشر حالة التحميل
  bool _isLoading = false;
  // قوائم لحفظ البيانات التي تم جلبها من Firestore
  List<ServiceProvider> _servicesNearYou = [];
  List<QuickCategory> _quickCategories = [];
  List<TopRatedProvider> _topRatedProviders = [];
  // (اختياري: متغير لحفظ رسائل الخطأ)
  // String? _errorMessage;

  // --- Getters ---
  // توفير وصول للقراءة فقط لمتغيرات الحالة للـ View
  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<ServiceProvider> get servicesNearYou => _servicesNearYou;
  List<QuickCategory> get quickCategories => _quickCategories;
  List<TopRatedProvider> get topRatedProviders => _topRatedProviders;
  // String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // يتطلب تمرير DbService عند إنشاء الـ ViewModel
  HomeViewModel(this._dbService) {
    // جلب البيانات الأولية عند إنشاء الـ ViewModel
    fetchData();
    // TODO: جلب اسم المستخدم الحقيقي من AuthService أو DbService لاحقاً
    // _loadUserName();
  }

  // --- الأفعال (Actions) ---

  // جلب كل البيانات المطلوبة للشاشة الرئيسية من Firestore
  Future<void> fetchData() async {
    _isLoading = true;
    // _errorMessage = null; // مسح الأخطاء السابقة
    notifyListeners(); // إخطار الواجهة بأن التحميل بدأ

    try {
      // جلب كل البيانات المطلوبة بالتوازي باستخدام Future.wait للكفاءة
      final results = await Future.wait([
        _dbService.getCategories(),         // جلب الفئات
        _dbService.getServicesNearYou(),    // جلب الخدمات القريبة
        _dbService.getTopRatedProviders(), // جلب الأعلى تقييماً
        // TODO: إضافة استدعاءات أخرى هنا إذا لزم الأمر (مثل جلب اسم المستخدم)
      ]);

      // تعيين النتائج التي تم جلبها لمتغيرات الحالة
      // التأكد من التحويل الصحيح للنوع ومعالجة القيمة null
      _quickCategories = results[0] as List<QuickCategory>? ?? [];
      _servicesNearYou = results[1] as List<ServiceProvider>? ?? [];
      _topRatedProviders = results[2] as List<TopRatedProvider>? ?? [];

      print("HomeViewModel: Data fetched successfully.");
      print("HomeViewModel: Found ${_topRatedProviders.length} top rated providers."); // للتأكد من العدد

    } catch (e) {
      // معالجة الأخطاء المحتملة أثناء جلب البيانات
      print("Error fetching home data in ViewModel: $e");
      // اختيارياً، قم بتعيين متغير حالة لرسالة الخطأ لعرضها في الواجهة
      // _errorMessage = "Could not load data. Please try again.";
    } finally {
      // التأكد من إيقاف حالة التحميل بغض النظر عن النجاح أو الفشل
      _isLoading = false;
      notifyListeners(); // إخطار الواجهة بأن التحميل انتهى
    }
  }

// مثال لجلب اسم المستخدم (يتم تنفيذه لاحقاً)
// Future<void> _loadUserName() async { ... }
}