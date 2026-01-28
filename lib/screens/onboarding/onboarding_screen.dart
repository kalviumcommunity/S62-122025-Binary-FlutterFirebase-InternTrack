// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/onboarding_model.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/widgets/purple_button.dart';
import '../../core/widgets/logo_badge.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/colors.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.onboardingKey, true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: AppConstants.animationDuration),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.pureBlack, AppColors.darkGray, AppColors.pureBlack]
                : [AppColors.pureWhite, AppColors.lightGray, AppColors.pureWhite],
          ),
        ),
        child: Stack(
          children: [
            // Gradient orbs
            GradientOrb(
              size: 400,
              alignment: Alignment.topRight,
              colors: [AppColors.purplePrimary, Colors.transparent],
              opacity: 0.3,
            ),
            GradientOrb(
              size: 350,
              alignment: Alignment.bottomLeft,
              colors: [AppColors.purpleLight, Colors.transparent],
              opacity: 0.25,
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LogoBadge(),
                        ThemeToggle(),
                      ],
                    ),
                  ),

                  SizedBox(height: AppConstants.spaceXL),

                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      OnboardingData.pages.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 40 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? LinearGradient(
                                  colors: [AppColors.purplePrimary, AppColors.purpleLight],
                                )
                              : null,
                          color: _currentPage != index
                              ? AppColors.mediumGray.withOpacity(0.3)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppConstants.spaceXXL),

                  // Content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: OnboardingData.pages.length,
                      itemBuilder: (context, index) {
                        final page = OnboardingData.pages[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: page.gradient,
                                  ),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.gradient[0].withOpacity(0.6),
                                      blurRadius: 40,
                                      offset: Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: AppConstants.spaceXXL + AppConstants.spaceL),

                              // Title
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayMedium,
                              ),

                              SizedBox(height: AppConstants.spaceL),

                              // Description
                              GlassContainer(
                                isDark: isDark,
                                borderRadius: AppConstants.radiusMedium,
                                padding: EdgeInsets.all(AppConstants.spaceL),
                                child: Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.all(AppConstants.spaceXL),
                    child: Row(
                      children: [
                        if (_currentPage < OnboardingData.pages.length - 1)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: TextButton(
                                onPressed: _completeOnboarding,
                                style: TextButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.spaceL,
                                    vertical: AppConstants.spaceM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  ),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.mediumGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        Spacer(),

                        PurpleButton(
                          text: _currentPage < OnboardingData.pages.length - 1
                              ? 'Next'
                              : 'Get Started',
                          onPressed: () {
                            if (_currentPage < OnboardingData.pages.length - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _completeOnboarding();
                            }
                          },
                          icon: _currentPage < OnboardingData.pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.rocket_launch_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}