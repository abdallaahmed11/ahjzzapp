import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الـ ViewModels المطلوبة
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reviews_viewmodel.dart'; // <-- 1. استيراد VM الجديد

// استيراد الـ Views (الشاشات) المطلوبة
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart';
import 'package:ahjizzzapp/views/profile_view.dart';
import 'package:ahjizzzapp/views/reviews_view.dart'; // <-- 2. استيراد View الجديد

// استيراد ملف الألوان
import 'package:ahjizzzapp/shared/app_colors.dart';

// استيراد الخدمات المطلوبة للـ ViewModels
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3. **** تحديث الـ MultiProvider ****
    return MultiProvider(
      providers: [
        // ViewModel للتحكم في التاب الحالي للداشبورد نفسه
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),

        // ViewModel للشاشة الرئيسية (Home)
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<DbService>()),
        ),

        // ViewModel لشاشة حجوزاتي (My Bookings)
        ChangeNotifierProvider(
          create: (context) => MyBookingsViewModel(
            context.read<DbService>(),
            context.read<AuthService>(),
          ),
        ),

        // **** إضافة ViewModel شاشة التقييمات ****
        ChangeNotifierProvider(
          create: (context) => ReviewsViewModel(
            context.read<DbService>(),
            context.read<AuthService>(),
          ),
        ),
        // **********************************

        // ViewModel لشاشة حسابي (Profile)
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            context.read<AuthService>(),
            context.read<DbService>(),
          ),
        ),
      ],
      // 4. **** تحديث Consumer و قائمة screens ****
      child: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {

          // قائمة الشاشات التي سيتم التنقل بينها
          final List<Widget> screens = [
            HomeView(),        // التاب 0
            MyBookingsView(),  // التاب 1
            ReviewsView(),     // التاب 2 (استبدال الشاشة الوهمية)
            ProfileView(),     // التاب 3
          ];

          return Scaffold(
            // استخدام IndexedStack يحافظ على حالة كل شاشة
            body: IndexedStack(
              index: dashboardViewModel.currentIndex,
              children: screens,
            ),
            // شريط التنقل السفلي
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: dashboardViewModel.currentIndex,
              onTap: (index) => dashboardViewModel.setIndex(index),

              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,

              // عناصر شريط التنقل
              items: const [
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
      // ******************************************
    );
  }
}