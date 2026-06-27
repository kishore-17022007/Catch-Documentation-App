import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'providers/app_state.dart';
import 'screens/language_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/trip_screen.dart';
import 'screens/catch_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Verify the runtime Firebase configuration during development.
  // This confirms the app is using the expected Firebase project / app ID.
  print('Firebase initialized with projectId=${Firebase.app().options.projectId} appId=${Firebase.app().options.appId}');

  // Disable App Verification for testing.
  // This allows you to use the "Phone numbers for testing" in Firebase Console
  // without dealing with reCAPTCHA or SMS region blocking during development.
  await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const CatchDocumentationApp(),
    ),
  );
}

class CatchDocumentationApp extends StatelessWidget {
  const CatchDocumentationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catch Documentation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // Deep Teal
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF0288D1), // Marine Blue
          background: const Color(0xFFF5F7FA), // Light Gray-Blue background
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LanguageSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/trip': (context) => const TripScreen(),
        '/catch': (context) => const CatchScreen(),
        '/sales': (context) => const SalesScreen(),
        '/analysis': (context) => const AnalysisScreen(),
        '/support': (context) => const SupportScreen(),
      },
    );
  }
}
