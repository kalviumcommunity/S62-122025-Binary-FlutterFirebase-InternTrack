import 'package:flutter/material.dart';

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingData {
  static List<OnboardingPage> pages = [
    OnboardingPage(
      icon: Icons.dashboard_customize_rounded,
      title: 'Centralized Dashboard',
      description: 'Track all your internship applications, deadlines, and opportunities in one organized space.',
    ),
    OnboardingPage(
      icon: Icons.groups_rounded,
      title: 'Mentor Collaboration',
      description: 'Connect with mentors privately, receive structured feedback, and accelerate your growth.',
    ),
    OnboardingPage(
      icon: Icons.sync_rounded,
      title: 'Real-Time Updates',
      description: 'Stay informed with instant notifications and seamless synchronization across all devices.',
    ),
  ];
}