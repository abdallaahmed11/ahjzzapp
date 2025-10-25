import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتهيئة شكل التاريخ
// استيراد الموديلات التي سنستقبلها
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // يحتوي على ProviderServiceModel
// استيراد الشاشة التالية للانتقال إليها
import 'package:ahjizzzapp/views/booking_payment_view.dart';
// استيراد خدمة قاعدة البيانات
import 'package:ahjizzzapp/services/db_service.dart';

class TimeSelectionViewModel extends ChangeNotifier {
  // --- الخدمات والبيانات المستلمة ---
  final DbService _dbService; // خدمة قاعدة البيانات
  final ServiceProvider provider;
  final ProviderServiceModel service;

  // --- (الحالة) State ---
  bool _isLoading = true; // البدء بحالة التحميل
  List<DateTime> _availableDates = []; // قائمة التواريخ (مثال: الـ 7 أيام القادمة)
  List<String> _availableTimes = []; // قائمة المواعيد المتاحة (المفلترة)
  DateTime? _selectedDate; // التاريخ الذي اختاره المستخدم
  String? _selectedTime;   // الوقت الذي اختاره المستخدم
  String? _errorMessage; // لعرض الأخطاء

  // --- (Getters) للقراءة الآمنة ---
  bool get isLoading => _isLoading;
  List<DateTime> get availableDates => _availableDates;
  List<String> get availableTimes => _availableTimes;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  String? get errorMessage => _errorMessage;

  // --- Constructor ---
  // يستقبل DbService والبيانات المطلوبة
  TimeSelectionViewModel({
    required DbService dbService,
    required this.provider,
    required this.service,
  }) : _dbService = dbService {
    // عند بدء التشغيل، قم بإنشاء التواريخ
    _generateMockDates();
    if (_availableDates.isNotEmpty) {
      // وجلب المواعيد تلقائياً لأول يوم
      selectDate(_availableDates.first);
    } else {
      _isLoading = false; // لا يوجد أيام لعرضها
    }
  }

  // --- دوال اللوجيك ---

  // دالة لإنشاء قائمة تواريخ (مثال: الـ 7 أيام القادمة)
  void _generateMockDates() {
    final now = DateTime.now();
    _availableDates = List.generate(7, (index) => now.add(Duration(days: index)));
  }

  // دالة لإنشاء قائمة (كل) المواعيد الممكنة في اليوم
  List<String> _generateAllPossibleSlots(DateTime date) {
    // (يمكن تعديل هذه القائمة لاحقاً لتعتمد على مواعيد عمل المزود)
    List<String> slots = [];
    // (مثال: من 9 صباحاً إلى 5 مساءً)
    DateTime startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    DateTime endTime = DateTime(date.year, date.month, date.day, 17, 0); // 5:00 PM

    // عدم عرض المواعيد الماضية في اليوم الحالي
    DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      // إذا كان اليوم هو اليوم الحالي، تأكد من أن وقت البدء ليس في الماضي
      if (now.isAfter(startTime)) {
        // ابدأ من أقرب 30 دقيقة قادمة
        int minutesToAdd = 30 - now.minute % 30;
        startTime = now.add(Duration(minutes: minutesToAdd));
        // تأكد من أن الساعة لم تتجاوز 9 (للتأكد من التقريب الصحيح)
        startTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
      }
    }

    while (startTime.isBefore(endTime)) {
      slots.add(DateFormat('h:mm a').format(startTime)); // Format as "9:00 AM"
      startTime = startTime.add(Duration(minutes: 30)); // زيادة 30 دقيقة
    }
    return slots;
  }

  // --- دالة جلب المواعيد المتاحة (مُحدثة) ---
  Future<void> _fetchAvailableTimesFor(DateTime date) async {
    _isLoading = true;
    _availableTimes = []; // تفريغ القائمة القديمة
    _selectedTime = null; // إلغاء اختيار الوقت
    _errorMessage = null; // مسح الأخطاء
    notifyListeners(); // إظهار التحميل

    try {
      // 1. جلب قائمة المواعيد المحجوزة من DbService
      List<String> bookedSlots =
      await _dbService.getBookedTimeSlots(provider.id, date);

      // 2. إنشاء القائمة الكاملة لكل المواعيد الممكنة لهذا اليوم
      List<String> allSlots = _generateAllPossibleSlots(date);

      // 3. فلترة القائمة: إزالة المواعيد المحجوزة
      _availableTimes = allSlots.where((slot) {
        // الاحتفاظ بالـ slot فقط إذا لم يكن موجوداً في bookedSlots
        return !bookedSlots.contains(slot);
      }).toList();

      if (_availableTimes.isEmpty) {
        _errorMessage = "No available slots for this day."; // رسالة إذا كانت كل المواعيد محجوزة
      }

    } catch (e) {
      print("Error fetching available times: $e");
      _errorMessage = "Could not load time slots."; // رسالة خطأ عامة
      _availableTimes = []; // إرجاع قائمة فارغة عند الخطأ
    } finally {
      _isLoading = false;
      notifyListeners(); // إخفاء التحميل وعرض المواعيد المتاحة
    }
  }
  // ------------------------------------

  // دالة عند اختيار تاريخ (مُحدثة)
  void selectDate(DateTime date) {
    // التأكد من أن التاريخ مختلف أو أن المواعيد لم تُجلب بعد
    // (نقارن اليوم فقط)
    if (_selectedDate == null ||
        _selectedDate!.day != date.day ||
        _selectedDate!.month != date.month ||
        _selectedDate!.year != date.year) {

      _selectedDate = date;
      // استدعاء الدالة الحقيقية لجلب المواعيد المتاحة لهذا اليوم
      _fetchAvailableTimesFor(date);
      // (notifyListeners() ستُستدعى داخل _fetchAvailableTimesFor)
    }
  }

  // دالة عند اختيار وقت (كما هي)
  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners(); // تحديث الواجهة (لإظهار زر التأكيد)
  }

  // دالة الانتقال للخطوة التالية (شاشة الدفع) (كما هي)
  void confirmTime(BuildContext context) {
    if (_selectedDate != null && _selectedTime != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingPaymentView(
            provider: provider,
            service: service,
            selectedDate: _selectedDate!,
            selectedTime: _selectedTime!,
          ),
          settings: RouteSettings(name: '/booking-payment'),
        ),
      );
    }
  }
}