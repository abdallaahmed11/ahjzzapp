import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/models/service_provider.dart'; // <-- استيراد
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/views/provider_details_view.dart'; // <-- استيراد

class MyBookingsViewModel extends ChangeNotifier {
  final DbService _dbService;
  final AuthService _authService;

  // --- الحالة (State) ---
  bool _isLoading = false; // للتحميل الرئيسي
  bool _isCancelling = false; // لحالة الإلغاء
  bool _isBookingAgain = false; // لحالة "احجز مرة أخرى"
  List<BookingModel> _allBookings = [];
  String? _errorMessage;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isCancelling => _isCancelling; // (اختياري: لعرض تحميل مختلف)
  bool get isBookingAgain => _isBookingAgain; // (اختياري: لعرض تحميل مختلف)
  String? get errorMessage => _errorMessage;

  List<BookingModel> get upcomingBookings =>
      _allBookings.where((b) => b.status == 'upcoming').toList();
  List<BookingModel> get completedBookings =>
      _allBookings.where((b) => b.status == 'completed' || b.status == 'rated').toList();
  List<BookingModel> get cancelledBookings =>
      _allBookings.where((b) => b.status == 'cancelled').toList();

  // --- Constructor ---
  MyBookingsViewModel(this._dbService, this._authService) {
    fetchBookings(); // جلب الحجوزات عند الإنشاء
  }

  // --- الأفعال (Actions) ---

  // دالة جلب الحجوزات
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");
      _allBookings = await _dbService.getUserBookings(userId);
    } catch (e) {
      print("Error fetching bookings in ViewModel: $e");
      _errorMessage = "Could not load your bookings.";
      _allBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة إلغاء الحجز
  Future<void> cancelBooking(String bookingId) async {
    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbService.updateBookingStatus(bookingId, 'cancelled');
      // إعادة تحميل القائمة من Firestore لضمان عرض البيانات المحدثة
      await fetchBookings(); // (هذه الدالة ستضبط isLoading و notify)

    } catch(e){
      print("Error cancelling booking: $e");
      _errorMessage = "Could not cancel booking.";
      notifyListeners();
    } finally {
      _isCancelling = false;
      // (fetchBookings ستهتم بـ isLoading = false)
      if (isLoading) notifyListeners(); // التأكد من إخفاء التحميل إذا فشل fetchBookings
    }
  }

  // **** دالة جديدة: "احجز مرة أخرى" ****
  Future<void> bookAgain(BuildContext context, BookingModel booking) async {
    _isBookingAgain = true;
    _errorMessage = null;
    notifyListeners(); // إظهار تحميل (اختياري)

    try {
      // 1. جلب بيانات مزود الخدمة الكاملة باستخدام الـ ID
      final ServiceProvider? provider = await _dbService.getProviderById(booking.providerId);

      // 2. التحقق من أن المزود لا يزال موجودًا
      if (provider != null && context.mounted) {
        // 3. الانتقال لشاشة تفاصيل المزود
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProviderDetailsView(provider: provider),
            settings: const RouteSettings(name: '/provider-details'),
          ),
        );
      } else if (provider == null) {
        throw Exception("This provider is no longer available.");
      }

    } catch (e) {
      print("Error during Book Again: $e");
      // عرض رسالة خطأ للمستخدم (باستخدام Snackbar مثلاً)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      _isBookingAgain = false;
      notifyListeners(); // إخفاء التحميل
    }
  }
// **********************************
}