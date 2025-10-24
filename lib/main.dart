import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Views
import 'package:ahjizzzapp/views/login_view.dart';
import 'package:ahjizzzapp/views/signup_view.dart';
import 'package:ahjizzzapp/views/reset_password_view.dart';
import 'package:ahjizzzapp/views/dashboard_view.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

// Shared
import 'package:ahjizzzapp/shared/app_colors.dart';

// Services
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// ViewModels (Auth Flow only, others are in Dashboard)
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';

// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // **** Run the app wrapped in MultiProvider ****
  runApp(
    MultiProvider(
      providers: [
        // --- SERVICES ---
        // Provide services at the top level so they are available everywhere
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DbService>(create: (_) => DbService()),

        // --- AUTH VIEWMODELS ---
        // Provide ViewModels needed before the Dashboard
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
      ],
      // The MyApp widget is now a child of MultiProvider
      child: MyApp(),
    ),
  );
  // ***********************************************
}

// MyApp no longer needs to be wrapped in MultiProvider here
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access AuthService provided by the MultiProvider above main()
    final authService = context.read<AuthService>(); // Now accessible

    return MaterialApp(
      title: 'Ahjiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( /* ... App Theme ... */ ),

      // **** Authentication State Handling ****
      // Use StreamProvider to listen to auth changes from the provided AuthService
      home: StreamProvider<User?>.value(
        // Read the auth service instance from the context provided by MultiProvider
        value: authService.authStateChanges,
        initialData: authService.currentUser, // Get initial state
        catchError: (_, err) { // Handle potential stream errors
          print("Error in auth stream: $err");
          return null; // Treat stream error as logged out
        },
        child: AuthWrapper(), // Widget that decides which screen to show
      ),
      // ************************************

      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpView(),
        '/reset-password': (context) => ResetPasswordView(),
        '/dashboard': (context) => DashboardView(),
        '/booking-confirmation': (context) => BookingConfirmationView(),
      },
    );
  }
}

// AuthWrapper remains the same
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read the user state from the StreamProvider above
    final user = Provider.of<User?>(context);

    if (user == null) {
      print("AuthWrapper: User is null, showing LoginView");
      return LoginView();
    } else {
      print("AuthWrapper: User is logged in (${user.uid}), showing DashboardView");
      return DashboardView();
    }
  }
}