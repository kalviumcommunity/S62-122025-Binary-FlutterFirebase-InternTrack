import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/onboarding_model.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/floating_orbs.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/app_logo.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 10000),
      vsync: this,
    )..repeat();

    _iconControllers = List.generate(
      OnboardingData.pages.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: AppConstants.iconAnimationDuration),
        vsync: this,
      ),
    );

    _iconAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _iconControllers[page].forward();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: AppConstants.animationDuration),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(controller: _backgroundController, isDark: isDark),
          FloatingOrbs(controller: _backgroundController, isDark: isDark, showMultiple: true),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(AppConstants.spacingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppLogo(isDark: isDark),
                      ThemeToggleButton(),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Page indicator
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      OnboardingData.pages.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 40 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? LinearGradient(
                                  colors: isDark
                                      ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
                                      : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
                                )
                              : null,
                          color: _currentPage != index
                              ? Color(0xFF6B6B6B).withOpacity(0.3)
                              : null,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                                        .withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Content pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: OnboardingData.pages.length,
                    itemBuilder: (context, index) {
                      final page = OnboardingData.pages[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingXLarge),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated icon with glassmorphic container
                            ScaleTransition(
                              scale: _iconAnimations[index],
                              child: Container(
                                width: AppConstants.iconContainerSize,
                                height: AppConstants.iconContainerSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusXXLarge),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _getGradientColors(index, isDark),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getGradientColors(index, isDark)[0]
                                          .withOpacity(0.5),
                                      blurRadius: 30,
                                      offset: Offset(0, 15),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXXLarge),
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
                                        page.icon,
                                        size: 75,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 60),

                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: isDark
                                    ? [Colors.white, Color(0xFFB8B8B8)]
                                    : [Colors.black, Color(0xFF4A4A4A)],
                              ).createShader(bounds),
                              child: Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),

                            SizedBox(height: AppConstants.spacingLarge),

                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Text(
                                page.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF6B6B6B),
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Action buttons
                Padding(
                  padding: EdgeInsets.all(AppConstants.spacingXLarge),
                  child: Row(
                    children: [
                      if (_currentPage < OnboardingData.pages.length - 1)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          ),
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      Spacer(),

                      GradientButton(
                        text: _currentPage < OnboardingData.pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        onPressed: () {
                          if (_currentPage < OnboardingData.pages.length - 1) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: AppConstants.pageTransitionDuration),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        isDark: isDark,
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
    );
  }

  List<Color> _getGradientColors(int index, bool isDark) {
    final gradients = isDark
        ? [
            [Color(0xFF6B4FBB), Color(0xFF4A90E2)],
            [Color(0xFF4A90E2), Color(0xFFE94B8C)],
            [Color(0xFFE94B8C), Color(0xFFFF6B35)],
          ]
        : [
            [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
            [Color(0xFFE94B8C), Color(0xFF4A90E2)],
            [Color(0xFFFF6B35), Color(0xFFE94B8C)],
          ];
    return gradients[index % gradients.length];
  }
}