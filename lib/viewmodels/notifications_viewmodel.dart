import 'package:flutter/material.dart';
import 'package:ahjizzzapp/models/notification_model.dart';
// import 'package:ahjizzzapp/services/notification_service.dart'; // (سنضيفه لاحقاً)

class NotificationsViewModel extends ChangeNotifier {
  // final NotificationService _notificationService; // (سنستخدمه لجلب البيانات)

  bool _isLoading = false;
  List<NotificationModel> _allNotifications = [];

  bool get isLoading => _isLoading;

  // قوائم مفلترة لكل تاب
  List<NotificationModel> get bookingNotifications =>
      _allNotifications.where((n) => n.type == NotificationType.booking).toList();

  List<NotificationModel> get offerNotifications =>
      _allNotifications.where((n) => n.type == NotificationType.offer).toList();

  // NotificationsViewModel(this._notificationService) { // (Constructor المستقبلي)
  NotificationsViewModel() { // (Constructor مؤقت)
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    // TODO: استبدل هذا ببيانات حقيقية (من Firestore أو Push Notifications)
    // _allNotifications = await _notificationService.getUserNotifications();

    // (بيانات وهمية مؤقتة مطابقة للتصميم)
    await Future.delayed(Duration(seconds: 1)); // محاكاة تحميل
    _allNotifications = [
      // Booking Notifications (Page 10)
      NotificationModel(
        id: 'b1', type: NotificationType.booking,
        title: 'Booking Confirmed', // [cite: 165]
        body: "Your appointment at Sam's Barbershop is confirmed for Thu, 23 Oct at 2:00 PM", // [cite: 166]
        timestamp: DateTime.now().subtract(Duration(hours: 2)), // "2 hours ago" [cite: 167]
      ),
      NotificationModel(
        id: 'b2', type: NotificationType.booking,
        title: 'Upcoming Appointment', // [cite: 168]
        body: "Reminder. You have an appointment tomorrow at Elite Auto Wash at 10:00 AM", // [cite: 169]
        timestamp: DateTime.now().subtract(Duration(hours: 5)), // "5 hours ago" [cite: 170]
      ),
      NotificationModel(
        id: 'b3', type: NotificationType.booking,
        title: 'Service Completed', // [cite: 171]
        body: "Your service at Sparkle Cleaners is complete. Rate your experience!", // [cite: 172]
        timestamp: DateTime.now().subtract(Duration(days: 1)), // "1 day ago" [cite: 173]
      ),
      // Offer Notifications (Page 11)
      NotificationModel(
        id: 'o1', type: NotificationType.offer,
        title: 'Welcome Offer! 30% OFF', // [cite: 178]
        body: "Get 30% off on your first booking. Use code: WELCOME30", // [cite: 179]
        timestamp: DateTime.now(), // "Just now" [cite: 180]
      ),
      NotificationModel(
        id: 'o2', type: NotificationType.offer,
        title: 'Weekend Special 15% OFF', // [cite: 181]
        body: "Book any service this weekend and get 15% off!", // [cite: 182]
        timestamp: DateTime.now().subtract(Duration(hours: 3)), // "3 hours ago" [cite: 183]
      ),
      NotificationModel(
        id: 'o3', type: NotificationType.offer,
        title: 'Refer a Friend 20% OFF', // [cite: 184]
        body: "Invite friends and both get 20% off your next booking!", // [cite: 185]
        timestamp: DateTime.now().subtract(Duration(days: 2)), // "2 days ago" [cite: 186]
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // دالة لوضع علامة "مقروء" على كل التنبيهات (مثال)
  void markAllAsRead() {
    // TODO: Implement logic to mark notifications as read
    print("Marking all notifications as read...");
    // (_allNotifications.forEach((n) => n.isRead = true); notifyListeners();)
  }

  // دالة لحساب الوقت المنقضي (مثل "2 hours ago")
  String timeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}