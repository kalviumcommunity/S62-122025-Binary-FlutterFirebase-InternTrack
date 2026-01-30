// lib\screens\profile\mentor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';

class MentorProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mentor = context.watch<MentorProvider>();
    final user = auth.currentUser!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Mentor Profile')),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          children: [
            GlassContainer(
              isDark: isDark,
              padding: EdgeInsets.all(AppConstants.spaceL),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.bluePrimary,
                    child: Text(
                      user.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(user.displayName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  Text(user.email, style: TextStyle(color: AppColors.mediumGray)),

                  SizedBox(height: 8),

                  Chip(
                    label: Text("Mentor"),
                    backgroundColor: AppColors.bluePrimary.withOpacity(.2),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppConstants.spaceXL),

            GlassContainer(
              isDark: isDark,
              padding: EdgeInsets.all(AppConstants.spaceL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat("Students", mentor.students.length),
                  _stat("Internships", mentor.totalInternships),
                ],
              ),
            ),

            Spacer(),

            ElevatedButton.icon(
              onPressed: () async {
                await auth.signOut();
              },
              icon: Icon(Icons.logout),
              label: Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, int value) {
    return Column(
      children: [
        Text(value.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title),
      ],
    );
  }
}
