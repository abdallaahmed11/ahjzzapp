import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
// استيراد مكتبة تهيئة التاريخ
import 'package:intl/intl.dart';
// استيراد الـ Modal الخاص بالتقييم
import 'package:ahjizzzapp/views/widgets/rate_service_modal.dart';

class MyBookingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استخدام Consumer لمراقبة التغييرات في MyBookingsViewModel
    return Consumer<MyBookingsViewModel>(
      builder: (context, viewModel, child) {
        // استخدام DefaultTabController لإدارة التابات
        return DefaultTabController(
          length: 3, // عدد التابات (Upcoming, Completed, Cancelled)
          child: Scaffold(
            appBar: AppBar(
              // تمكين زر الرجوع التلقائي (إذا فتحت هذه الشاشة من مكان آخر غير الداشبورد)
              automaticallyImplyLeading: false,
              title: Text('My Bookings'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1, // لإظهار خط بسيط تحت الـ AppBar
              bottom: TabBar(
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey[600],
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: viewModel.isLoading
            // إظهار مؤشر التحميل أثناء جلب البيانات
                ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
            // عرض محتوى التابات بعد التحميل
                : TabBarView(
              children: [
                // محتوى تاب Upcoming
                _buildBookingList(viewModel.upcomingBookings, viewModel),
                // محتوى تاب Completed
                _buildBookingList(viewModel.completedBookings, viewModel),
                // محتوى تاب Cancelled
                _buildBookingList(viewModel.cancelledBookings, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widget لعرض قائمة الحجوزات ---
  Widget _buildBookingList(List<BookingModel> bookings, MyBookingsViewModel viewModel) {
    // رسالة في حالة عدم وجود حجوزات
    if (bookings.isEmpty) {
      return Center(child: Text('No bookings found in this category.'));
    }

    // عرض الحجوزات في قائمة قابلة للسكرول
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        // بناء كرت الحجز لكل عنصر في القائمة
        return _buildBookingCard(context, booking, viewModel); // <-- تمرير context هنا
      },
    );
  }

  // --- Widget لعرض كرت الحجز ---
  Widget _buildBookingCard(BuildContext context, BookingModel booking, MyBookingsViewModel viewModel) { // <-- استقبال context
    // تهيئة التاريخ والوقت باستخدام مكتبة intl
    final formattedDate = DateFormat('EEE, d MMM').format(booking.dateTime); // e.g., Thu, 23 Oct
    final formattedTime = DateFormat('h:mm a').format(booking.dateTime);     // e.g., 2:00 PM

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المزود والحالة (Status Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.providerName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // عرض شارة الحالة حسب نوع الحجز
                if (booking.status == BookingStatus.upcoming)
                  _buildStatusBadge('Confirmed', Colors.green),
                if (booking.status == BookingStatus.cancelled)
                  _buildStatusBadge('Cancelled', Colors.red),
              ],
            ),
            SizedBox(height: 4),
            // اسم الخدمة
            Text(
              booking.serviceName,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            // التاريخ والوقت مع أيقونات
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(formattedDate),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(formattedTime),
              ],
            ),
            SizedBox(height: 12),
            Divider(), // خط فاصل
            SizedBox(height: 12),
            // السعر والأزرار في الأسفل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.price,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
                // عرض الأزرار المناسبة حسب حالة الحجز
                if (booking.status == BookingStatus.upcoming)
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () { /* TODO: Implement Reschedule logic */ },
                        child: Text('Reschedule'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => viewModel.cancelBooking(booking.id), // استدعاء دالة الإلغاء
                        child: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                if (booking.status == BookingStatus.completed)
                  Row(
                    children: [
                      OutlinedButton(
                        // --- التعديل هنا ---
                        onPressed: () {
                          // إظهار الـ Modal الخاص بالتقييم عند الضغط
                          showRateServiceModal(context, booking.id, booking.providerName);
                        },
                        // ------------------
                        child: Text('Rate Service'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () { /* TODO: Implement Book Again logic */ },
                        child: Text('Book Again'),
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                if (booking.status == BookingStatus.cancelled)
                  ElevatedButton(
                    onPressed: () { /* TODO: Implement Book Again logic */ },
                    child: Text('Book Again'),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Widget لـ Status Badge ---
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}