import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isStudent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                
                // Logo Icon
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isStudent
                          ? [Color(0xFF4A90E2), Color(0xFF357ABD)]
                          : [Color(0xFF5CA0F2), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isStudent ? Color(0xFF4A90E2) : Color(0xFF5CA0F2))
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    isStudent ? Icons.school_rounded : Icons.people_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 32),

                // Title
                Text(
                  'InternTrack',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 12),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    isStudent
                        ? 'Manage your internship journey with ease'
                        : 'Guide students toward their career goals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7A8A99),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: 48),

                // Role Selection Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFE8EDF2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A90E2).withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Continue as',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7A8A99),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Student Option
                      _buildRoleOption(
                        isSelected: isStudent,
                        icon: Icons.school_rounded,
                        title: 'Student',
                        subtitle: 'Track internships & get guidance',
                        color: Color(0xFF4A90E2),
                        onTap: () => setState(() => isStudent = true),
                      ),

                      SizedBox(height: 12),

                      // Mentor Option
                      _buildRoleOption(
                        isSelected: !isStudent,
                        icon: Icons.people_rounded,
                        title: 'Mentor',
                        subtitle: 'Support and guide students',
                        color: Color(0xFF5CA0F2),
                        onTap: () => setState(() => isStudent = false),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthScreen(isStudent: isStudent),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isStudent ? Color(0xFF4A90E2) : Color(0xFF5CA0F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Color(0xFFE8EDF2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Color(0xFF7A8A99),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? color : Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A8A99),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}