import 'package:flutter/material.dart';
// استيراد الموديلات والخدمات المطلوبة
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/time_selection_view.dart';
import 'package:ahjizzzapp/models/review_model.dart'; // (استيراد موديل التقييم)

// **** موديل الخدمة: يُعرّف هنا لأنه خاص بهذه الواجهة ****
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
// *****************************************************

class ProviderDetailsViewModel extends ChangeNotifier {
  final DbService _dbService;
  final ServiceProvider provider;

  // --- الحالة (State) ---
  bool _isLoading = true; // البدء بحالة التحميل
  List<ProviderServiceModel> _services = []; // قائمة الخدمات الفعلية
  List<ReviewModel> _reviews = []; // قائمة التقييمات
  ProviderServiceModel? _selectedService; // الخدمة التي يختارها المستخدم
  String? _errorMessage; // لعرض أي أخطاء

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<ProviderServiceModel> get services => _services;
  List<ReviewModel> get reviews => _reviews;
  ProviderServiceModel? get selectedService => _selectedService;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // يتطلب DbService ومعلومات المزود
  ProviderDetailsViewModel(this._dbService, this.provider) {
    // جلب قائمة الخدمات فور إنشاء الـ ViewModel
    fetchProviderDetails(); // <-- 1. استخدام الاسم الجديد هنا
  }

  // --- الأفعال (Actions) ---

  // **** 2. تعديل اسم الدالة هنا ****
  // (اسمها اتغير من fetchProviderServices إلى fetchProviderDetails)
  Future<void> fetchProviderDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // إظهار التحميل

    try {
      // جلب الخدمات والتقييمات بالتوازي
      final results = await Future.wait([
        _dbService.getServicesForProvider(provider.id),
        _dbService.getReviewsForProvider(provider.id),
      ]);

      // تعيين النتائج
      _services = results[0] as List<ProviderServiceModel>;
      _reviews = results[1] as List<ReviewModel>;

      print("ProviderDetailsViewModel: Fetched ${_services.length} services and ${_reviews.length} reviews.");

    } catch (e) {
      print("Error fetching provider details in ViewModel: $e");
      _errorMessage = "Could not load provider details.";
      _services = [];
      _reviews = []; // تفريغ القوائم عند الخطأ
    } finally {
      _isLoading = false;
      notifyListeners(); // إخفاء التحميل وتحديث الواجهة
    }
  }
  // **********************************

  // دالة اختيار الخدمة
  void selectService(ProviderServiceModel service) {
    _selectedService = service;
    notifyListeners(); // تحديث الواجهة لإظهار الاختيار وتفعيل الزر
  }

  // دالة الانتقال لشاشة اختيار الوقت
  void proceedToBooking(BuildContext context) {
    if (_selectedService != null) {
      print("Proceeding to book: ${provider.name} - ${_selectedService!.name}");
      // الانتقال باستخدام MaterialPageRoute وتمرير البيانات اللازمة
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TimeSelectionView(
            provider: provider,        // تمرير المزود
            service: _selectedService!, // تمرير الخدمة المختارة
          ),
          settings: const RouteSettings(name: '/time-selection'), // اسم المسار
        ),
      );
    }
  }
}