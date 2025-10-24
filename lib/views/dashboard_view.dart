import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الـ ViewModels المطلوبة
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart'; // ViewModel حجوزاتي
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';    // ViewModel حسابي

// استيراد الـ Views (الشاشات) المطلوبة
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart'; // واجهة حجوزاتي
import 'package:ahjizzzapp/views/profile_view.dart';    // واجهة حسابي
// (سنضيف واجهة التقييمات لاحقاً)
// import 'package:ahjizzzapp/views/reviews_view.dart';

// استيراد ملف الألوان
import 'package:ahjizzzapp/shared/app_colors.dart';

// استيراد الخدمات المطلوبة للـ ViewModels
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. استخدام MultiProvider لتوفير كل الـ ViewModels المطلوبة للشاشات داخل الداشبورد
    // يتم توفير الخدمات (AuthService, DbService) من الـ MultiProvider الأعلى في main.dart
    return MultiProvider(
      providers: [
        // ViewModel للتحكم في التاب الحالي للداشبورد نفسه
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),

        // ViewModel للشاشة الرئيسية (Home) - يعتمد على DbService
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<DbService>()),
        ),

        // ViewModel لشاشة حجوزاتي (My Bookings) - يعتمد على DbService و AuthService
        ChangeNotifierProvider(
          create: (context) => MyBookingsViewModel(
            context.read<DbService>(),
            context.read<AuthService>(),
          ),
        ),

        // ViewModel لشاشة حسابي (Profile) - يعتمد على DbService و AuthService
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            context.read<AuthService>(),
            context.read<DbService>(),
          ),
        ),

        // (سنضيف ViewModel لشاشة التقييمات Reviews هنا لاحقاً)
      ],
      // 2. استخدام Consumer لمراقبة التاب الحالي في DashboardViewModel
      child: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {

          // 3. قائمة الشاشات التي سيتم التنقل بينها بناءً على التاب المختار
          final List<Widget> screens = [
            HomeView(),        // الشاشة الأولى
            MyBookingsView(),  // الشاشة الثانية
            Center(child: Text('Reviews Page (TBD)')), // شاشة وهمية مؤقتة للتقييمات
            ProfileView(),     // الشاشة الرابعة
          ];

          // 4. بناء الـ Scaffold الذي يحتوي على الجسم وشريط التنقل السفلي
          return Scaffold(
            // استخدام IndexedStack يحافظ على حالة كل شاشة (Tab) عند التنقل بينها
            // (لا يعيد بناء الشاشة كل مرة نرجع لها)
            body: IndexedStack(
              index: dashboardViewModel.currentIndex, // التاب الحالي
              children: screens, // قائمة الشاشات
            ),
            // شريط التنقل السفلي
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: dashboardViewModel.currentIndex, // تحديد التاب النشط
              onTap: (index) => dashboardViewModel.setIndex(index), // استدعاء دالة تغيير التاب عند الضغط

              type: BottomNavigationBarType.fixed, // لإظهار كل الـ labels حتى لو كانوا أكثر من 3
              selectedItemColor: kPrimaryColor,   // لون الأيقونة والنص النشط (الأخضر)
              unselectedItemColor: Colors.grey,     // لون الأيقونة والنص غير النشط (الرمادي)
              showUnselectedLabels: true,           // إظهار النصوص دائماً
              selectedFontSize: 12,                // حجم خط النص النشط
              unselectedFontSize: 12,               // حجم خط النص غير النشط

              // تعريف عناصر (أيقونات ونصوص) شريط التنقل
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),    // أيقونة غير نشطة
                  activeIcon: Icon(Icons.home),       // أيقونة نشطة
                  label: 'Home',                      // النص
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'My Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border_outlined),
                  activeIcon: Icon(Icons.star),
                  label: 'Reviews',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}