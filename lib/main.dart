import 'package:flutter/material.dart';

void main() {
  runApp(InternTrackApp());
}

class InternTrackApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4361EE),
          primary: Color(0xFF4361EE),
          secondary: Color(0xFF3A0CA3),
          tertiary: Color(0xFF7209B7),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isStudent = true;

  void toggleRole() {
    setState(() {
      isStudent = !isStudent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFEFF2FF),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon with better design
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isStudent
                          ? [Color(0xFF4361EE), Color(0xFF3A0CA3)]
                          : [Color(0xFF7209B7), Color(0xFFF72585)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isStudent
                            ? Color(0xFF4361EE).withOpacity(0.3)
                            : Color(0xFF7209B7).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isStudent ? Icons.school_outlined : Icons.people_alt_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Welcome Text
                Text(
                  'InternTrack',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Description Text
                Text(
                  isStudent
                      ? 'Your gateway to meaningful internships and professional growth'
                      : 'Empower the next generation of professionals with your guidance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Role Selection Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE2E8F0).withOpacity(0.5),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Continue as',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4A5568),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Student Option
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isStudent
                              ? Color(0xFF4361EE).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isStudent
                                ? Color(0xFF4361EE)
                                : Color(0xFFE2E8F0),
                            width: isStudent ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => setState(() => isStudent = true),
                          leading: Icon(
                            Icons.school_outlined,
                            color: isStudent
                                ? Color(0xFF4361EE)
                                : Color(0xFFA0AEC0),
                          ),
                          title: Text(
                            'Student',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isStudent
                                  ? Color(0xFF4361EE)
                                  : Color(0xFF4A5568),
                            ),
                          ),
                          subtitle: Text(
                            'Find and track internships',
                            style: TextStyle(
                              fontSize: 12,
                              color: isStudent
                                  ? Color(0xFF4361EE).withOpacity(0.7)
                                  : Color(0xFFA0AEC0),
                            ),
                          ),
                          trailing: isStudent
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF4361EE),
                                )
                              : null,
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Mentor Option
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: !isStudent
                              ? Color(0xFF7209B7).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !isStudent
                                ? Color(0xFF7209B7)
                                : Color(0xFFE2E8F0),
                            width: !isStudent ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => setState(() => isStudent = false),
                          leading: Icon(
                            Icons.people_alt_outlined,
                            color: !isStudent
                                ? Color(0xFF7209B7)
                                : Color(0xFFA0AEC0),
                          ),
                          title: Text(
                            'Mentor',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !isStudent
                                  ? Color(0xFF7209B7)
                                  : Color(0xFF4A5568),
                            ),
                          ),
                          subtitle: Text(
                            'Guide and support students',
                            style: TextStyle(
                              fontSize: 12,
                              color: !isStudent
                                  ? Color(0xFF7209B7).withOpacity(0.7)
                                  : Color(0xFFA0AEC0),
                            ),
                          ),
                          trailing: !isStudent
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF7209B7),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Continue Button
                ElevatedButton(
                  onPressed: toggleRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isStudent
                        ? Color(0xFF4361EE)
                        : Color(0xFF7209B7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Skip for now option
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}