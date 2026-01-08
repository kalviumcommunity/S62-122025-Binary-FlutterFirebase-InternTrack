import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s62_122025_binary_flutterfirebase_interntrack/firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(InternTrackApp());
}

class InternTrackApp extends StatelessWidget {
  const InternTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4A90E2),
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFF5CA0F2),
        ),
        scaffoldBackgroundColor: Color(0xFFF8FAFB),
        fontFamily: 'Inter',
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2C3E50),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7A8A99),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        
        return WelcomeScreen();
      },
    );
  }
}