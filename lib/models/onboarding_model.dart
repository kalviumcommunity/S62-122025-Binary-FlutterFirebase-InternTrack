// onboarding_model.dart
import 'package:flutter/material.dart';

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class OnboardingData {
  static List<OnboardingPage> pages = [
    OnboardingPage(
      icon: Icons.dashboard_rounded,
      title: 'Unified Dashboard',
      description: 'View internships, statuses, deadlines, and feedback in one place. No more juggling emails, job portals, and messaging apps.',
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    OnboardingPage(
      icon: Icons.supervisor_account_rounded,
      title: 'Private Mentor Collaboration',
      description: 'Invite-only mentor access ensures security and relevance. Receive structured, private feedback to guide your career growth.',
      gradient: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    ),
    OnboardingPage(
      icon: Icons.cloud_sync_rounded,
      title: 'Real-Time Data Sync',
      description: 'Updates reflect instantly without manual refresh. Experience seamless synchronization across all your devices.',
      gradient: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    ),
  ];
}