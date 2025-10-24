import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الـ ViewModels المطلوبة
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';

// استيراد الـ Views المطلوبة
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart';
import 'package:ahjizzzapp/views/profile_view.dart';

// استيراد ملف الألوان
import 'package:ahjizzzapp/shared/app_colors.dart';

// استيراد خدمة المصادقة (AuthService) لتمريرها للـ ProfileViewModel
import 'package:ahjizzzapp/services/auth_service.dart';

// (سنضيف خدمة قاعدة البيانات DbService لاحقاً)
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. استخدام MultiProvider لتوفير كل الـ ViewModels المطلوبة للشاشات داخل الداشبورد
    return MultiProvider(
      providers: [
        // ViewModel للتحكم في التاب الحالي للداشبورد نفسه
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),

        // ViewModel للشاشة الرئيسية (Home)
        // TODO: مستقبلاً، سنمرر خدمة قاعدة البيانات DbService هنا
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<DbService>()), // <-- التعديل هنا
        ),
        // ViewModel لشاشة حجوزاتي (My Bookings)
        // TODO: مستقبلاً، سنمرر خدمة قاعدة البيانات DbService هنا
        ChangeNotifierProvider(create: (_) => MyBookingsViewModel(/* context.read<DbService>() */)),

        // ViewModel لشاشة حسابي (Profile)
        // (نمرر خدمة AuthService الموجودة مسبقاً في الـ context)
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(context.read<AuthService>()),
        ),

        // (سنضيف ViewModel لشاشة التقييمات Reviews هنا لاحقاً)
      ],
      // 2. استخدام Consumer لمراقبة التاب الحالي في DashboardViewModel
      child: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {

          // 3. قائمة الشاشات التي سيتم التنقل بينها
          final List<Widget> screens = [
            HomeView(),
            MyBookingsView(), // <-- تم استبدال الشاشة الوهمية
            Center(child: Text('Reviews Page')),    // شاشة وهمية مؤقتة
            ProfileView(), // <-- تم استبدال الشاشة الوهمية
          ];

          // 4. بناء الـ Scaffold مع شريط التنقل السفلي
          return Scaffold(
            // استخدام IndexedStack للحفاظ على حالة الشاشات عند التنقل
            body: IndexedStack(
              index: dashboardViewModel.currentIndex,
              children: screens,
            ),
            // شريط التنقل السفلي
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: dashboardViewModel.currentIndex,
              onTap: (index) => dashboardViewModel.setIndex(index), // استدعاء دالة تغيير التاب

              type: BottomNavigationBarType.fixed, // لإظهار كل الـ labels
              selectedItemColor: kPrimaryColor,   // لون الأيقونة النشطة
              unselectedItemColor: Colors.grey,     // لون الأيقونة غير النشطة
              showUnselectedLabels: true,           // إظهار الـ label دائماً
              selectedFontSize: 12,
              unselectedFontSize: 12,

              // تعريف عناصر شريط التنقل
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
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