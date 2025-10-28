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
import 'package:ahjizzzapp/views/update_profile_view.dart';
import 'package:ahjizzzapp/views/search_view.dart'; // <-- 1. استيراد شاشة البحث الجديدة

// Shared
import 'package:ahjizzzapp/shared/app_colors.dart';

// Services
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// ViewModels
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/update_profile_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/search_viewmodel.dart'; // <-- 2. استيراد VM البحث الجديد

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

        // --- VIEWMODELS (Non-Dashboard) ---
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

        // **** 3. إضافة VM البحث ****
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) => SearchViewModel(context.read<DbService>()),
        ),
        // ***************************
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return MaterialApp(
      title: 'Ahjiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( /* ... App Theme ... */ ),

      // Authentication State Handling
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
        '/update-profile': (context) => UpdateProfileView(),
        '/search': (context) => SearchView(), // <-- المسار الجديد
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