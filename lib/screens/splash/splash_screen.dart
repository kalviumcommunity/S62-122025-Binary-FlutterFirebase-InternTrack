import 'package:flutter/material.dart';
import 'dart:async';
import '../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/animated_background.dart';
import '../../core/constants/app_constants.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late AnimationController _backgroundController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: AppConstants.backgroundAnimationDuration),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(milliseconds: AppConstants.particleAnimationDuration),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _rotateController.forward();

    Timer(Duration(milliseconds: AppConstants.splashDuration), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(AppConstants.onboardingKey) ?? false;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                hasSeenOnboarding ? AuthWrapper() : OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(controller: _backgroundController, isDark: isDark),

          // Floating particles
          ...List.generate(12, (index) {
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final offset = (_particleController.value + (index * 0.1)) % 1.0;
                final x = size.width * (0.1 + (index % 4) * 0.25);
                final y = size.height * offset;
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: (0.3 - (offset * 0.3)).clamp(0.0, 1.0),
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isDark
                              ? [Colors.white, Colors.white.withOpacity(0)]
                              : [Colors.black26, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Glassmorphic circles
          Positioned(
            top: -150,
            right: -100,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: AppConstants.orbSizeLarge,
                height: AppConstants.orbSizeLarge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [
                            Color(0xFF6B4FBB).withOpacity(0.15),
                            Color(0xFF4A90E2).withOpacity(0.05),
                            Colors.transparent,
                          ]
                        : [
                            Color(0xFF4A90E2).withOpacity(0.1),
                            Color(0xFF6B4FBB).withOpacity(0.05),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -200,
            left: -150,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [
                            Color(0xFFE94B8C).withOpacity(0.12),
                            Color(0xFFFF6B35).withOpacity(0.06),
                            Colors.transparent,
                          ]
                        : [
                            Color(0xFFFF6B35).withOpacity(0.08),
                            Color(0xFFE94B8C).withOpacity(0.04),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 0.1,
                          child: Container(
                            width: AppConstants.logoSize,
                            height: AppConstants.logoSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
                                    : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                                      .withOpacity(0.5),
                                  blurRadius: 40,
                                  offset: Offset(0, 20),
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.rocket_launch_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: AppConstants.spacingXXLarge),

                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDark
                          ? [Colors.white, Color(0xFFB8B8B8)]
                          : [Colors.black, Color(0xFF4A4A4A)],
                    ).createShader(bounds),
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B6B6B),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated loading indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading your experience...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B6B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}