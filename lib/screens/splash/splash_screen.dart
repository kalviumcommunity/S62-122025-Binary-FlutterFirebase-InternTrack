import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../app/app.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    Timer(Duration(milliseconds: AppConstants.splashDuration), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(AppStrings.onboardingKey) ?? false;

      if (mounted) {
        // Check auth state
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.checkAuthState();

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                hasSeenOnboarding ? AuthWrapper() : OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

            // Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.purplePrimary, AppColors.purpleLight],
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purplePrimary.withOpacity(0.6),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.work_outline_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXL),

                      // App Name
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),

                      SizedBox(height: AppConstants.spaceM),

                      // Tagline
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceL,
                              vertical: AppConstants.spaceS + 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              AppStrings.appTagline,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.mediumGray,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXL + AppConstants.spaceL),

                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.purplePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}