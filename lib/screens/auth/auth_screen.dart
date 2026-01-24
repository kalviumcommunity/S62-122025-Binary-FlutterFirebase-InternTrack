import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/widgets/purple_button.dart';
import '../../core/widgets/logo_badge.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../dashboard/student_dashboard.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (_nameController.text.isNotEmpty) {
          await FirebaseAuth.instance.currentUser?.updateDisplayName(
            _nameController.text.trim(),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StudentDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(AppConstants.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LogoBadge(),
                        ThemeToggle(),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                    // Title
                    Text(
                      _isLogin ? 'Welcome\nBack' : 'Create\nAccount',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),

                    SizedBox(height: AppConstants.spaceM),

                    GlassContainer(
                      isDark: isDark,
                      borderRadius: AppConstants.radiusSmall,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                        vertical: AppConstants.spaceS + 2,
                      ),
                      child: Text(
                        _isLogin
                            ? 'Sign in to continue your journey'
                            : 'Start organizing your career today',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceXXL + AppConstants.spaceL),

                    // Form
                    GlassContainer(
                      isDark: isDark,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!_isLogin) ...[
                              GlassTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'Enter your name',
                                prefixIcon: Icons.person_outline_rounded,
                                isDark: isDark,
                              ),
                              SizedBox(height: AppConstants.spaceL),
                            ],
                            
                            GlassTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'your@email.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: AppConstants.spaceL),
                            
                            GlassTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              isDark: isDark,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.mediumGray,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            PurpleButton(
                              text: _isLogin ? 'Sign In' : 'Create Account',
                              onPressed: _submit,
                              isLoading: _isLoading,
                              icon: Icons.arrow_forward_rounded,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceL),

                    // Toggle mode
                    Center(
                      child: TextButton(
                        onPressed: _toggleMode,
                        child: RichText(
                          text: TextSpan(
                            text: _isLogin
                                ? "Don't have an account? "
                                : 'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.mediumGray,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: _isLogin ? 'Sign Up' : 'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.purplePrimary,
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
            ),
          ],
        ),
      ),
    );
  }
}