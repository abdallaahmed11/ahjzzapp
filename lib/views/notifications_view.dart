import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/notifications_viewmodel.dart';
import 'package:ahjizzzapp/models/notification_model.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. توفير الـ ViewModel لهذه الشاشة فقط (لأنها ليست جزءاً من الداشبورد الرئيسي)
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(),
      child: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          // 2. استخدام DefaultTabController لإدارة التابات
          return DefaultTabController(
            length: 2, // عدد التابات (Bookings, Offers) [cite: 163, 164, 176, 177]
            child: Scaffold(
              appBar: AppBar(
                title: Text('Notifications'), // [cite: 161, 174]
                backgroundColor: kLightBackgroundColor,
                elevation: 1,
                leading: IconButton( // زر الرجوع
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [ // زر "Mark all read" [cite: 162, 175]
                  TextButton(
                    onPressed: viewModel.markAllAsRead,
                    child: Text(
                      'Mark all read',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  )
                ],
                bottom: TabBar(
                  indicatorColor: kPrimaryColor,
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  tabs: [
                    Tab(text: 'Bookings'), // [cite: 163, 176]
                    Tab(text: 'Offers'),   // [cite: 164, 177]
                  ],
                ),
              ),
              backgroundColor: kLightBackgroundColor,
              body: viewModel.isLoading
                  ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : TabBarView(
                children: [
                  // محتوى تاب Bookings
                  _buildNotificationList(viewModel.bookingNotifications, viewModel),
                  // محتوى تاب Offers
                  _buildNotificationList(viewModel.offerNotifications, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget لعرض قائمة التنبيهات ---
  Widget _buildNotificationList(List<NotificationModel> notifications, NotificationsViewModel viewModel) {
    if (notifications.isEmpty) {
      return Center(child: Text('No notifications in this category yet.'));
    }

    // استخدام ListView.separated لإضافة فاصل بين العناصر
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5), // فاصل بسيط
      itemBuilder: (context, index) {
        final notification = notifications[index];
        // بناء عنصر التنبيه
        return ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          // (يمكن إضافة أيقونة حسب نوع التنبيه هنا)
          // leading: Icon( notification.type == NotificationType.booking ? Icons.calendar_today : Icons.local_offer),
          title: Text(
            notification.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(notification.body),
              SizedBox(height: 8),
              Text(
                viewModel.timeAgo(notification.timestamp), // عرض الوقت المنقضي [cite: 167, 170, 173, 180, 183, 186]
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          isThreeLine: true, // للسماح بعرض أكثر من سطر في الـ subtitle
          onTap: () {
            // TODO: تحديد ما يحدث عند الضغط على التنبيه
            print("Tapped on notification: ${notification.title}");
          },
        );
      },
    );
  }
}