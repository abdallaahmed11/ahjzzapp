import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/models/booking_model.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:ahjizzzapp/views/widgets/rate_service_modal.dart';
// استيراد شاشة تفاصيل المزود (لأن دالة bookAgain تحتاجها)
import 'package:ahjizzzapp/views/provider_details_view.dart';


class MyBookingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyBookingsViewModel>(
      builder: (context, viewModel, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('My Bookings'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              bottom: TabBar(
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey[600],
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: viewModel.isLoading
                ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : viewModel.errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 40),
                    SizedBox(height: 10),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: viewModel.fetchBookings, // زر إعادة المحاولة
                      child: Text("Retry"),
                    )
                  ],
                ),
              ),
            )
                : TabBarView(
              children: [
                _buildBookingList(context, viewModel.upcomingBookings, viewModel),
                _buildBookingList(context, viewModel.completedBookings, viewModel),
                _buildBookingList(context, viewModel.cancelledBookings, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widget لعرض قائمة الحجوزات ---
  Widget _buildBookingList(BuildContext context, List<BookingModel> bookings, MyBookingsViewModel viewModel) {
    if (bookings.isEmpty) {
      return Center(
          child: Text(
            'No bookings found in this category.',
            style: TextStyle(color: Colors.grey[600]),
          ));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking, viewModel);
      },
    );
  }

  // --- Widget لعرض كرت الحجز الواحد ---
  Widget _buildBookingCard(BuildContext context, BookingModel booking, MyBookingsViewModel viewModel) {
    final formattedDate = DateFormat('EEE, d MMM').format(booking.dateTime);
    final formattedTime = DateFormat('h:mm a').format(booking.dateTime);

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
            Row( // السطر الأول: الاسم والحالة
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.providerName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                // شارة الحالة
                if (booking.status == 'upcoming')
                  _buildStatusBadge('Confirmed', Colors.green),
                if (booking.status == 'cancelled')
                  _buildStatusBadge('Cancelled', Colors.red),
                if (booking.status == 'completed')
                  _buildStatusBadge('Completed', Colors.blue),
                if (booking.status == 'rated')
                  _buildStatusBadge('Rated', Colors.grey),
              ],
            ),
            SizedBox(height: 4),
            Text( // اسم الخدمة
              booking.serviceName,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Row( // التاريخ والوقت
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
            Divider(),
            SizedBox(height: 12),
            Row( // السطر الأخير: السعر والأزرار
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center, // لمحاذاة السعر والأزرار
              children: [
                Text( // السعر
                  booking.price,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
                ),
                // أزرار الإجراءات
                _buildActionButtons(context, booking, viewModel),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Widget لعرض أزرار الإجراءات (مُعدل) ---
  Widget _buildActionButtons(BuildContext context, BookingModel booking, MyBookingsViewModel viewModel) {

    // 1. الحجز القادم (Upcoming)
    if (booking.status == 'upcoming') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () { /* TODO: Implement Reschedule logic */ },
            child: Text('Reschedule'),
          ),
          SizedBox(width: 8),
          // زر الإلغاء الفعّال
          OutlinedButton(
            onPressed: () {
              // (يمكن إضافة تأكيد هنا)
              viewModel.cancelBooking(booking.id); // استدعاء دالة الإلغاء
            },
            child: Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[200]!),
            ),
          ),
        ],
      );
    }

    // 2. الحجز المكتمل (Completed - لم يُقيّم بعد)
    else if (booking.status == 'completed') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر التقييم الفعّال
          OutlinedButton(
            onPressed: () {
              // إظهار الـ Modal وتمرير البيانات اللازمة
              showRateServiceModal(
                context,
                bookingId: booking.id,
                providerId: booking.providerId, // <-- تمرير الـ ID الحقيقي
                providerName: booking.providerName,
              );
            },
            child: Text('Rate Service'),
          ),
          SizedBox(width: 8),
          // **** زر "احجز مرة أخرى" (الجديد) ****
          ElevatedButton(
            onPressed: () {
              // استدعاء الدالة الجديدة في الـ ViewModel
              viewModel.bookAgain(context, booking);
            },
            child: Text('Book Again'),
          ),
          // **********************************
        ],
      );
    }

    // 3. الحجز الملغى (Cancelled) أو المقيم (Rated)
    else if (booking.status == 'cancelled' || booking.status == 'rated') {
      // يعرض "Book Again" فقط
      // **** زر "احجز مرة أخرى" (الجديد) ****
      return ElevatedButton(
        onPressed: () {
          // استدعاء الدالة الجديدة في الـ ViewModel
          viewModel.bookAgain(context, booking);
        },
        child: Text('Book Again'),
      );
      // **********************************
    }

    // حالة غير معروفة
    else {
      return SizedBox.shrink(); // عنصر فارغ
    }
  }

  // --- Widget لشارة الحالة (Status Badge) ---
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}