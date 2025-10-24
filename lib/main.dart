import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:provider/provider.dart';          // Import Provider

// Import Views (Screens)
import 'package:ahjizzzapp/views/login_view.dart';
import 'package:ahjizzzapp/views/signup_view.dart';
import 'package:ahjizzzapp/views/reset_password_view.dart';
import 'package:ahjizzzapp/views/dashboard_view.dart';

// Import Shared Resources
import 'package:ahjizzzapp/shared/app_colors.dart';

// Import Services
import 'package:ahjizzzapp/services/auth_service.dart';
// TODO: Import DbService later
import 'package:ahjizzzapp/services/db_service.dart';

// Import ViewModels for Authentication flow
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';

// Import firebase_options.dart if you used FlutterFire CLI for setup
// import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized (required before Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase (reads google-services.json / GoogleService-Info.plist)
  await Firebase.initializeApp(
    // Use this line if you configured Firebase using FlutterFire CLI
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Run the application
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 4. Use MultiProvider to make Services and ViewModels available throughout the app
    return MultiProvider(
      providers: [
        // --- SERVICES ---
        // Services are typically provided once and don't change state that affects UI directly.
        Provider<AuthService>(create: (_) => AuthService()),
        // TODO: Provide DbService when created
        Provider<DbService>(create: (_) => DbService()),

        // --- VIEWMODELS (for screens not managed by DashboardView's MultiProvider) ---
        // ViewModels manage state and notify listeners, hence ChangeNotifierProvider.
        // We provide the AuthService (read from context) to ViewModels that need it.
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ResetPasswordViewModel>(
          create: (context) => ResetPasswordViewModel(context.read<AuthService>()),
        ),

        // Note: ViewModels for Home, MyBookings, Profile, etc., are provided
        // within the DashboardView itself, as they belong to that section of the app.
      ],
      // 5. The main MaterialApp widget
      child: MaterialApp(
        title: 'Ahjiz App',
        debugShowCheckedModeBanner: false, // Hides the debug banner

        // --- App Theme ---
        theme: ThemeData(
          primaryColor: kPrimaryColor, // Main branding color
          scaffoldBackgroundColor: kLightBackgroundColor, // Default background for screens
          fontFamily: 'Roboto', // Default font (ensure you add it to pubspec if using a custom font)
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor), // Generates related colors
          useMaterial3: true, // Enables Material 3 design features
          appBarTheme: const AppBarTheme( // Consistent AppBar style
            elevation: 1,
            backgroundColor: kLightBackgroundColor,
            foregroundColor: Colors.black87, // Color for title and icons
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData( // Consistent Button style
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // --- Navigation ---
        // TODO: Implement logic here to check auth state and navigate
        //       to '/dashboard' if logged in, otherwise '/login'.
        initialRoute: '/login', // Start with the login screen

        // Define all the app's named routes
        routes: {
          '/login': (context) => LoginView(),
          '/signup': (context) => SignUpView(),
          '/reset-password': (context) => ResetPasswordView(),
          '/dashboard': (context) => DashboardView(),
          // TODO: Add routes for other screens like:
          // '/provider-details': (context) => ProviderDetailsView(...), // Requires argument handling
          // '/time-selection': (context) => TimeSelectionView(...),     // Requires argument handling
          // '/booking-payment': (context) => BookingPaymentView(...),  // Requires argument handling
          // '/notifications': (context) => NotificationsView(),
          // '/rate-service': (context) => RateServiceView(...),        // Requires argument handling
        },
      ),
    );
  }
}