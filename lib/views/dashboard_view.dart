import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

// استيراد الـ ViewModels المطلوبة
import 'package:ahjizzzapp/viewmodels/dashboard_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/my_bookings_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reviews_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/admin_viewmodel.dart'; // (لسه محتاجينه عشان نعمل تحديث للـ role)

// استيراد الـ Views (الشاشات) المطلوبة
import 'package:ahjizzzapp/views/home_view.dart';
import 'package:ahjizzzapp/views/my_bookings_view.dart';
import 'package:ahjizzzapp/views/profile_view.dart';
import 'package:ahjizzzapp/views/reviews_view.dart';

// استيراد ملف الألوان والخدمات
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // **** 1. حذف AdminViewModel من هنا ****
        // ChangeNotifierProvider(
        //   create: (context) => AdminViewModel( ... ),
        // ),
        // **********************************

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
                // (الـ ViewModel الخاص بالتاب اللي رايحله بيعمل refresh)
                if (dashboardViewModel.currentIndex != index) {
                  if (index == 1) { context.read<MyBookingsViewModel>().fetchBookings(); }
                  if (index == 2) { context.read<ReviewsViewModel>().fetchUserReviews(); }
                  if (index == 3) {
                    context.read<ProfileViewModel>().loadUserProfile();
                    // **** 2. تحديث الدور عند الضغط على البروفايل ****
                    context.read<AdminViewModel>().checkUserRole();
                    // ******************************************
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

              // (الـ items مترجمة)
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'nav_home'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'nav_bookings'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border_outlined),
                  activeIcon: Icon(Icons.star),
                  label: 'nav_reviews'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'nav_profile'.tr(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}