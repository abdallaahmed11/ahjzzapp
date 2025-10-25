import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // لتهيئة شكل التاريخ
// استيراد الـ ViewModel
import 'package:ahjizzzapp/viewmodels/time_selection_viewmodel.dart';
// استيراد الموديلات
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
// استيراد الألوان
import 'package:ahjizzzapp/shared/app_colors.dart';
// استيراد الخدمات المطلوبة للـ ViewModel
import 'package:ahjizzzapp/services/db_service.dart';

class TimeSelectionView extends StatelessWidget {
  // استقبال البيانات من الشاشة السابقة
  final ServiceProvider provider;
  final ProviderServiceModel service;

  const TimeSelectionView({
    Key? key,
    required this.provider,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // **** تحديث الـ ChangeNotifierProvider ****
    return ChangeNotifierProvider(
      create: (ctx) => TimeSelectionViewModel(
        dbService: ctx.read<DbService>(), // <-- تمرير DbService
        provider: provider,               // <-- تمرير المزود
        service: service,                 // <-- تمرير الخدمة
      ),
      // ----------------------------------------
      child: Consumer<TimeSelectionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Select Date & Time'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. شريط اختيار التاريخ الأفقي
                _buildDateSelector(context, viewModel),
                Divider(height: 1, thickness: 1), // خط فاصل

                // 2. شبكة المواعيد المتاحة
                Expanded(
                  // عرض مؤشر التحميل أو الخطأ أو الشبكة
                  child: viewModel.isLoading
                      ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  // عرض رسالة الخطأ إذا حدث خطأ *و* القائمة فارغة
                      : viewModel.errorMessage != null && viewModel.availableTimes.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        viewModel.errorMessage!, // عرض رسالة الخطأ
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                  // عرض شبكة المواعيد
                      : _buildTimeSlotsGrid(context, viewModel),
                ),
              ],
            ),
            // 3. زر التأكيد (يظهر فقط عند اختيار وقت)
            bottomNavigationBar: viewModel.selectedTime != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => viewModel.confirmTime(context), // استدعاء دالة التأكيد
                style: ElevatedButton.styleFrom(
                  // (يستخدم الـ style من الـ Theme)
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Confirm Time'),
              ),
            )
                : null, // إخفاء الزر إذا لم يتم اختيار وقت
          );
        },
      ),
    );
  }

  // --- Widget: شريط اختيار التاريخ ---
  Widget _buildDateSelector(BuildContext context, TimeSelectionViewModel viewModel) {
    return Container(
      height: 90, // ارتفاع ثابت للشريط
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // سكرول أفقي
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.availableDates.length, // عدد الأيام
        itemBuilder: (context, index) {
          final date = viewModel.availableDates[index];
          // التحقق إذا كان هذا التاريخ هو المختار حالياً (بمقارنة اليوم والشهر والسنة)
          final bool isSelected = viewModel.selectedDate != null &&
              date.year == viewModel.selectedDate!.year &&
              date.month == viewModel.selectedDate!.month &&
              date.day == viewModel.selectedDate!.day;

          return InkWell(
            onTap: () => viewModel.selectDate(date), // استدعاء دالة اختيار التاريخ
            child: Container(
              width: 65, // عرض كل عنصر تاريخ
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.transparent, // تغيير اللون عند الاختيار
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey[300]!, // تغيير الإطار
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اسم اليوم (مثال: Fri)
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6),
                  // رقم اليوم (مثال: 24)
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget: شبكة المواعيد ---
  Widget _buildTimeSlotsGrid(BuildContext context, TimeSelectionViewModel viewModel) {
    // رسالة إذا كانت القائمة فارغة (بعد الفلترة)
    if (viewModel.availableTimes.isEmpty && !viewModel.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            // عرض رسالة الخطأ أو رسالة "لا توجد مواعيد"
            viewModel.errorMessage ?? 'No available time slots for the selected date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // عرض المواعيد في شبكة (GridView)
    return GridView.builder(
      padding: EdgeInsets.all(16),
      // تحديد 3 أعمدة
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5, // النسبة بين العرض والارتفاع للزر
        crossAxisSpacing: 10,  // المسافة الأفقية
        mainAxisSpacing: 10,   // المسافة الرأسية
      ),
      itemCount: viewModel.availableTimes.length,
      itemBuilder: (context, index) {
        final time = viewModel.availableTimes[index];
        // التحقق إذا كان هذا الوقت هو المختار حالياً
        final isSelected = viewModel.selectedTime == time;

        return OutlinedButton(
          onPressed: () => viewModel.selectTime(time), // استدعاء دالة اختيار الوقت
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
            foregroundColor: isSelected ? kPrimaryColor : Colors.black87,
            side: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!, // تغيير الإطار
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(time),
        );
      },
    );
  }
}