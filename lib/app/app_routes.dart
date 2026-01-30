// lib/app/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/student_dashboard.dart';
import '../screens/dashboard/mentor_dashboard.dart';
import '../screens/internships/internship_list_screen.dart';
import '../screens/internships/add_internship_screen.dart';
import '../screens/internships/edit_internship_screen.dart';
import '../screens/internships/internship_detail_screen.dart';
import '../screens/internships/archived_internships_screen.dart';
import '../screens/student/invite_mentor_screen.dart';
import '../screens/mentor/mentor_students_screen.dart';
import '../screens/mentor/mentor_student_detail_screen.dart';
import '../screens/mentor/mentor_internship_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/mentor_profile_screen.dart';
import '../screens/profile/mentorship_management_screen.dart';
import '../screens/profile/resume_upload_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  // Common routes
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String resumeUpload = '/resume-upload';
  
  // Student routes
  static const String studentDashboard = '/student-dashboard';
  static const String internshipList = '/internship-list';
  static const String addInternship = '/add-internship';
  static const String editInternship = '/edit-internship';
  static const String internshipDetail = '/internship-detail';
  static const String archivedInternships = '/archived-internships';
  static const String inviteMentor = '/invite-mentor';
  static const String mentorshipManagement = '/mentorship-management';
  
  // Mentor routes
  static const String mentorDashboard = '/mentor-dashboard';
  static const String mentorStudents = '/mentor-students';
  static const String mentorStudentDetail = '/mentor-student-detail';
  static const String mentorInternshipDetail = '/mentor-internship-detail';
  static const String mentorProfile = '/mentor-profile'; 

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => OnboardingScreen(),
    auth: (context) => AuthScreen(),
    studentDashboard: (context) => StudentDashboard(),
    mentorDashboard: (context) => MentorDashboard(),
    internshipList: (context) => InternshipListScreen(),
    addInternship: (context) => AddInternshipScreen(),
    archivedInternships: (context) => ArchivedInternshipsScreen(),
    inviteMentor: (context) => InviteMentorScreen(),
    mentorshipManagement: (context) => MentorshipManagementScreen(),
    mentorStudents: (context) => MentorStudentsScreen(),
    profile: (context) => ProfileScreen(),
    mentorProfile: (context) => MentorProfileScreen(),
    notifications: (context) => NotificationsScreen(),
    resumeUpload: (context) => ResumeUploadScreen(),
  };

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
      case mentorStudentDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => MentorStudentDetailScreen(student: args['student']),
        );
      case mentorInternshipDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => MentorInternshipDetailScreen(internship: args['internship']),
        );
      default:
        return null;
    }
  }
}