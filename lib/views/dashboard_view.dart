import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. استيراد المكتبة

// (باقي الـ imports كما هي)
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reviews_viewmodel.dart';
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart';
import 'package:ahjizzzapp/views/profile_view.dart';
import 'package:ahjizzzapp/views/reviews_view.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // (كل الـ Providers كما هي)
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel(context.read<DbService>(), context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => MyBookingsViewModel(context.read<DbService>(), context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => ReviewsViewModel(context.read<DbService>(), context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(context.read<AuthService>(), context.read<DbService>())),
      ],
      child: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {

          final List<Widget> screens = [
            HomeView(),
            MyBookingsView(),
            ReviewsView(),
            ProfileView(),
          ];

          return Scaffold(
            body: IndexedStack(
              index: dashboardViewModel.currentIndex,
              children: screens,
            ),
            // شريط التنقل السفلي
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: dashboardViewModel.currentIndex,
              onTap: (index) {
                // (دالة onTap كما هي)
                if (dashboardViewModel.currentIndex != index) {
                  if (index == 1) {
                    context.read<MyBookingsViewModel>().fetchBookings();
                  }
                  if (index == 2) {
                    context.read<ReviewsViewModel>().fetchUserReviews();
                  }
                  if (index == 3) {
                    // (سنحتاج إضافة الدالة دي في الـ ViewModel)
                    // context.read<ProfileViewModel>().loadUserProfile();
                  }
                }
                dashboardViewModel.setIndex(index);
              },

              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,

              // **** 2. ترجمة الـ Labels ****
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'nav_home'.tr(), // "Home"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'nav_bookings'.tr(), // "My Bookings"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border_outlined),
                  activeIcon: Icon(Icons.star),
                  label: 'nav_reviews'.tr(), // "Reviews"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'nav_profile'.tr(), // "Profile"
                ),
              ],
              // **************************
            ),
          );
        },
      ),
    );
  }
}