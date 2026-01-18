import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/theme_toggle_button.dart';
import '../../../widgets/animated_background.dart';
import '../../../widgets/floating_orbs.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../core/constants/app_constants.dart';
import '../home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: AppConstants.backgroundAnimationDuration),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: Duration(milliseconds: AppConstants.animationDuration),
      vsync: this,
    );

    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_formAnimation);

    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _formController.reset();
    _formController.forward();
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
          MaterialPageRoute(builder: (_) => HomeScreen()),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(controller: _backgroundController, isDark: isDark),
          FloatingOrbs(controller: _backgroundController, isDark: isDark),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppLogo(isDark: isDark),
                        ThemeToggleButton(),
                      ],
                    ),

                    SizedBox(height: size.height * 0.08),

                    // Welcome text
                    FadeTransition(
                      opacity: _formAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDark
                                  ? [Colors.white, Color(0xFFB8B8B8)]
                                  : [Colors.black, Color(0xFF4A4A4A)],
                            ).createShader(bounds),
                            child: Text(
                              _isLogin ? 'Welcome\nBack!' : 'Create\nAccount',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Text(
                              _isLogin
                                  ? 'Sign in to continue your journey'
                                  : 'Start organizing your career today',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B6B6B),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50),

                    // Form
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _formAnimation,
                        child: GlassmorphicContainer(
                          isDark: isDark,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (!_isLogin) ...[
                                  CustomTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'Enter your name',
                                    prefixIcon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                  ),
                                  SizedBox(height: 20),
                                ],
                                
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'Enter your email',
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
                                
                                SizedBox(height: 20),
                                
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  isDark: isDark,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Color(0xFF6B6B6B),
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

                                SizedBox(height: AppConstants.spacingXLarge),

                                GradientButton(
                                  text: _isLogin ? 'Sign In' : 'Create Account',
                                  onPressed: _submit,
                                  isDark: isDark,
                                  isLoading: _isLoading,
                                  icon: Icons.arrow_forward_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 28),

                    // Toggle mode
                    FadeTransition(
                      opacity: _formAnimation,
                      child: Center(
                        child: TextButton(
                          onPressed: _toggleMode,
                          child: RichText(
                            text: TextSpan(
                              text: _isLogin
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: _isLogin ? 'Sign Up' : 'Sign In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}