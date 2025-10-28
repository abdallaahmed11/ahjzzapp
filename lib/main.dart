import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// **** 1. استيراد مكتبة الترجمة ****
import 'package:easy_localization/easy_localization.dart';

// (استيراد كل الـ Views)
import 'package:ahjizzzapp/views/login_view.dart';
import 'package:ahjizzzapp/views/signup_view.dart';
import 'package:ahjizzzapp/views/reset_password_view.dart';
import 'package:ahjizzzapp/views/dashboard_view.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';
import 'package:ahjizzzapp/views/update_profile_view.dart';
import 'package:ahjizzzapp/views/search_view.dart';

// (استيراد الألوان)
import 'package:ahjizzzapp/shared/app_colors.dart';

// (استيراد الخدمات)
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// (استيراد الـ ViewModels)
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/update_profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/search_viewmodel.dart';

// (استيراد ملف خيارات Firebase إذا كنت تستخدمه)
// import 'firebase_options.dart';

void main() async {
  // التأكد من تهيئة كل شيء قبل التشغيل
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // **** 2. تهيئة مكتبة الترجمة ****
  await EasyLocalization.ensureInitialized();
  // ********************************

  print("Firebase initialized successfully!");

  runApp(
    // **** 3. تغليف التطبيق بـ EasyLocalization ****
    EasyLocalization(
      // اللغات التي يدعمها التطبيق
      supportedLocales: [
        Locale('en'), // اللغة الإنجليزية
        Locale('ar'), // اللغة العربية
      ],
      // المسار اللي فيه ملفات الترجمة
      path: 'assets/translations',
      // اللغة الافتراضية في حالة عدم وجود لغة الجهاز
      fallbackLocale: Locale('en'),
      // الـ MultiProvider أصبح بداخلها
      child: MultiProvider(
        providers: [
          // --- الخدمات (Services) ---
          Provider<AuthService>(create: (_) => AuthService()),
          Provider<DbService>(create: (_) => DbService()),

          // --- ViewModels (التي تعمل خارج الداشبورد) ---
          ChangeNotifierProvider<LoginViewModel>(
            create: (context) => LoginViewModel(context.read<AuthService>()),
          ),
          ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(
              context.read<AuthService>(),
              context.read<DbService>(),
            ),
          ),
          ChangeNotifierProvider<ResetPasswordViewModel>(
            create: (context) => ResetPasswordViewModel(context.read<AuthService>()),
          ),
          ChangeNotifierProvider<UpdateProfileViewModel>(
            create: (context) => UpdateProfileViewModel(
              context.read<AuthService>(),
              context.read<DbService>(),
            ),
          ),
          ChangeNotifierProvider<SearchViewModel>(
            create: (context) => SearchViewModel(context.read<DbService>()),
          ),
          // (الـ ViewModels الخاصة بالداشبورد يتم توفيرها داخل DashboardView)
        ],
        child: MyApp(), // تشغيل التطبيق
      ),
    ),
    // ********************************************
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // قراءة خدمة المصادقة (آمن الآن لأن الـ Provider فوق MyApp)
    final authService = context.read<AuthService>();

    return MaterialApp(
      title: 'Ahjiz App', // (يمكن ترجمة هذا لاحقًا)
      debugShowCheckedModeBanner: false,

      // **** 4. ربط الـ MaterialApp بالترجمة ****
      locale: context.locale, // تحديد اللغة الحالية من المكتبة
      supportedLocales: context.supportedLocales, // اللغات المدعومة
      localizationsDelegates: context.localizationDelegates, // (مهم جداً)
      // *************************************

      // (الثيم الخاص بالتطبيق كما هو)
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kLightBackgroundColor,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          backgroundColor: kLightBackgroundColor,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[400]!),
            foregroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),

      // (التحقق من حالة المصادقة كما هو)
      home: StreamProvider<User?>.value(
        value: authService.authStateChanges,
        initialData: authService.currentUser,
        catchError: (_, err) => null,
        child: AuthWrapper(),
      ),

      // (المسارات كما هي)
      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpView(),
        '/reset-password': (context) => ResetPasswordView(),
        '/dashboard': (context) => DashboardView(),
        '/booking-confirmation': (context) => BookingConfirmationView(),
        '/update-profile': (context) => UpdateProfileView(),
        '/search': (context) => SearchView(),
      },
    );
  }
}

// (AuthWrapper widget كما هو)
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return LoginView();
    } else {
      return DashboardView();
    }
  }
}