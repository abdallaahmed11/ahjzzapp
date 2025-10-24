enum NotificationType { booking, offer }

class NotificationModel {
  final String id;
  final NotificationType type; // 'Bookings' or 'Offers'
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead; // (اختياري: لتحديد إذا تمت قراءة التنبيه)

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}