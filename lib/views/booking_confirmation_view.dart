import 'package:flutter/material.dart';
import 'package:ahjizzzapp/shared/app_colors.dart'; // لاستخدام اللون الأساسي

class BookingConfirmationView extends StatelessWidget {
  // (اختياري: يمكن استقبال بيانات الحجز هنا لعرضها لو أردنا)
  // final String providerName;
  // final String serviceName;
  // final DateTime dateTime;

  // const BookingConfirmationView({
  //   Key? key,
  //   required this.providerName,
  //   required this.serviceName,
  //   required this.dateTime,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. أيقونة علامة الصح الكبيرة
              Icon(
                Icons.check_circle_outline_rounded,
                color: kPrimaryColor,
                size: 100,
              ),
              SizedBox(height: 32),

              // 2. رسالة التأكيد
              Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Your appointment has been successfully booked.\nYou will receive a confirmation and reminders soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40),

              // (اختياري: عرض ملخص بسيط للحجز هنا)
              // Text('Provider: $providerName'),
              // Text('Service: $serviceName'),
              // Text('Date & Time: ...'),
              // SizedBox(height: 40),

              // 3. زر العودة للرئيسية
              ElevatedButton(
                onPressed: () {
                  // العودة للشاشة الرئيسية (الداشبورد) وحذف كل الشاشات السابقة في رحلة الحجز
                  Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard' || route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}