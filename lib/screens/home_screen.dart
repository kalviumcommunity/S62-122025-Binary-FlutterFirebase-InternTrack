import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: Color(0xFF7A8A99),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF7A8A99),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      setState(() => _isLoggingOut = true);

      try {
        await FirebaseAuth.instance.signOut();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoggingOut = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Color(0xFFE74C3C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: Color(0xFF7A8A99)),
              tooltip: 'Sign Out',
              onPressed: _isLoggingOut ? null : _handleLogout,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'You are successfully signed in',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7A8A99),
                      ),
                    ),

                    SizedBox(height: 28),

                    // User Info
                    _buildInfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Email Address',
                      value: user?.email ?? 'No email',
                      color: Color(0xFF4A90E2),
                    ),

                    SizedBox(height: 16),

                    _buildInfoTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Status',
                      value: user?.emailVerified == true ? 'Verified' : 'Not Verified',
                      color: user?.emailVerified == true
                          ? Color(0xFF27AE60)
                          : Color(0xFFF39C12),
                    ),

                    SizedBox(height: 16),

                    _buildInfoTile(
                      icon: Icons.fingerprint_rounded,
                      label: 'User ID',
                      value: user?.uid.substring(0, 12) ?? 'N/A',
                      color: Color(0xFF4A90E2),
                      isMonospace: true,
                    ),

                    SizedBox(height: 28),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoggingOut ? null : _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: Color(0xFFE74C3C).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoggingOut
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Info Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFE8EDF2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF4A90E2),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your session is securely managed by Firebase Authentication',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A99),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isMonospace = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFE8EDF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8A99),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
