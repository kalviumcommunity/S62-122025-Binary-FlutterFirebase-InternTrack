import 'package:flutter/material.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/student_dashboard.dart';
import '../screens/internships/internship_list_screen.dart';
import '../screens/internships/add_internship_screen.dart';
import '../screens/internships/edit_internship_screen.dart';
import '../screens/internships/internship_detail_screen.dart';
import '../screens/internships/archived_internships_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String internshipList = '/internship-list';
  static const String addInternship = '/add-internship';
  static const String editInternship = '/edit-internship';
  static const String internshipDetail = '/internship-detail';
  static const String archivedInternships = '/archived-internships';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => OnboardingScreen(),
    auth: (context) => AuthScreen(),
    dashboard: (context) => StudentDashboard(),
    internshipList: (context) => InternshipListScreen(),
    addInternship: (context) => AddInternshipScreen(), // FIXED: Added this route
    archivedInternships: (context) => ArchivedInternshipsScreen(),
    profile: (context) => ProfileScreen(),
  };

  // For routes that need arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editInternship:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => EditInternshipScreen(internship: args['internship']),
        );
      case internshipDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute( 
          builder: (context) => InternshipDetailScreen(internship: args['internship']),
        );
      default:
        return null;
    }
  }
}