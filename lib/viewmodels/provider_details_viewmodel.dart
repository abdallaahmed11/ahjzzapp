import 'package:flutter/material.dart';
// استيراد الموديلات والخدمات المطلوبة
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // <-- استيراد DbService
import 'package:ahjizzzapp/views/time_selection_view.dart'; // <-- استيراد الشاشة التالية

// **** موديل الخدمة: يُعرّف هنا لأنه خاص بهذه الواجهة ****
// (يمكن نقله لملف models/provider_service_model.dart إذا أردت)
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
  final DbService _dbService; // الخدمة لجلب البيانات
  final ServiceProvider provider; // معلومات المزود الأساسية

  // --- الحالة (State) ---
  bool _isLoading = true; // البدء بحالة التحميل
  List<ProviderServiceModel> _services = []; // قائمة الخدمات الفعلية
  ProviderServiceModel? _selectedService; // الخدمة التي يختارها المستخدم
  String? _errorMessage; // لعرض أي أخطاء

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<ProviderServiceModel> get services => _services;
  ProviderServiceModel? get selectedService => _selectedService;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // يتطلب DbService ومعلومات المزود
  ProviderDetailsViewModel(this._dbService, this.provider) {
    // جلب قائمة الخدمات فور إنشاء الـ ViewModel
    fetchProviderServices();
  }

  // --- الأفعال (Actions) ---

  // **** دالة جلب الخدمات (مُحدثة) ****
  Future<void> fetchProviderServices() async {
    _isLoading = true;
    _errorMessage = null; // مسح الأخطاء السابقة
    // (لا نحتاج notifyListeners() هنا لأننا سنفعلها في finally)

    try {
      // استدعاء الدالة الجديدة من DbService باستخدام ID المزود
      _services = await _dbService.getServicesForProvider(provider.id);
      print("ProviderDetailsViewModel: Fetched ${_services.length} services.");
    } catch (e) {
      print("Error fetching provider services in ViewModel: $e");
      _errorMessage = "Could not load services for this provider.";
      _services = []; // قائمة فارغة في حالة الخطأ
    } finally {
      _isLoading = false;
      notifyListeners(); // إخفاء التحميل وتحديث الواجهة بالبيانات (أو الخطأ)
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