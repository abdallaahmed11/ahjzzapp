import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الـ ViewModels المطلوبة
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart'; // <-- الملف الذي عدلناه
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reviews_viewmodel.dart';

// استيراد الـ Views (الشاشات) المطلوبة
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart';
import 'package:ahjizzzapp/views/profile_view.dart';
import 'package:ahjizzzapp/views/reviews_view.dart';

// استيراد ملف الألوان
import 'package:ahjizzzapp/shared/app_colors.dart';

// استيراد الخدمات المطلوبة للـ ViewModels
import 'package:ahjizzzapp/services/auth_service.dart'; // <-- نحتاجه هنا
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModel للتحكم في التاب الحالي
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),

        // **** 1. تعديل طريقة إنشاء HomeViewModel ****
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            context.read<DbService>(),   // تمرير DbService
            context.read<AuthService>(), // <-- تمرير AuthService
          ),
        ),
        // *******************************************

        // ViewModel لشاشة حجوزاتي (My Bookings)
        ChangeNotifierProvider(
          create: (context) => MyBookingsViewModel(
            context.read<DbService>(),
            context.read<AuthService>(),
          ),
        ),

        // ViewModel لشاشة التقييمات (Reviews)
        ChangeNotifierProvider(
          create: (context) => ReviewsViewModel(
            context.read<DbService>(),
            context.read<AuthService>(),
          ),
        ),

        // ViewModel لشاشة حسابي (Profile)
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            context.read<AuthService>(),
            context.read<DbService>(),
          ),
        ),
      ],
      child: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {

          // قائمة الشاشات
          final List<Widget> screens = [
            HomeView(),        // التاب 0
            MyBookingsView(),  // التاب 1
            ReviewsView(),     // التاب 2
            ProfileView(),     // التاب 3
          ];

          return Scaffold(
            body: IndexedStack(
              index: dashboardViewModel.currentIndex,
              children: screens,
            ),
            // شريط التنقل السفلي
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: dashboardViewModel.currentIndex,

              // **** 2. تعديل onTap لتحديث ProfileViewModel ****
              onTap: (index) {
                // التحقق إذا كان المستخدم ضغط على تاب مختلف
                if (dashboardViewModel.currentIndex != index) {

                  // إذا ضغط على "My Bookings" (index 1)، اطلب تحديث البيانات
                  if (index == 1) {
                    print("Dashboard: Tapped My Bookings, refreshing data...");
                    context.read<MyBookingsViewModel>().fetchBookings();
                  }

                  // إذا ضغط على "Reviews" (index 2)، اطلب تحديث البيانات
                  if (index == 2) {
                    print("Dashboard: Tapped Reviews, refreshing data...");
                    context.read<ReviewsViewModel>().fetchUserReviews();
                  }

                  // إذا ضغط على "Profile" (index 3)، اطلب تحديث البيانات
                  if (index == 3) {
                    print("Dashboard: Tapped Profile, refreshing data...");
                    // (سنحتاج لإضافة دالة refresh في ProfileViewModel)
                    // context.read<ProfileViewModel>()._loadUserProfile();
                  }
                }

                // 5. أخيرًا، قم بتغيير التاب
                dashboardViewModel.setIndex(index);
              },
              // *********************************************

              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,

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
    );
  }
}