import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Views
import 'package:ahjizzzapp/views/login_view.dart';
import 'package:ahjizzzapp/views/signup_view.dart';
import 'package:ahjizzzapp/views/reset_password_view.dart';
import 'package:ahjizzzapp/views/dashboard_view.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';
import 'package:ahjizzzapp/views/update_profile_view.dart'; // <-- 1. استيراد الشاشة الجديدة

// Shared
import 'package:ahjizzzapp/shared/app_colors.dart';

// Services
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// ViewModels
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/update_profile_viewmodel.dart'; // <-- 2. استيراد الـ ViewModel الجديد

// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) { print("Error initializing Firebase: $e"); }

  runApp(
    MultiProvider(
      providers: [
        // --- SERVICES ---
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DbService>(create: (_) => DbService()),

        // --- VIEWMODELS (Auth Flow) ---
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

        // **** 3. إضافة الـ ViewModel الجديد ****
        // (نضيفه هنا لأنه يُستخدم خارج الداشبورد الرئيسي)
        ChangeNotifierProvider<UpdateProfileViewModel>(
          create: (context) => UpdateProfileViewModel(
            context.read<AuthService>(),
            context.read<DbService>(),
          ),
        ),
        // **********************************
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // (الوصول للخدمة هنا آمن لأن الـ Provider فوق MyApp)
    final authService = context.read<AuthService>();

    return MaterialApp(
      title: 'Ahjiz App',
      debugShowCheckedModeBanner: false,
      // (الثيم كما هو)
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

      // **** 4. إضافة المسار (Route) الجديد ****
      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpView(),
        '/reset-password': (context) => ResetPasswordView(),
        '/dashboard': (context) => DashboardView(),
        '/booking-confirmation': (context) => BookingConfirmationView(),
        '/update-profile': (context) => UpdateProfileView(), // <-- المسار الجديد
      },
      // *************************************
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