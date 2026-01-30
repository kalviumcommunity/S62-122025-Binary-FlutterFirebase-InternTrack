// lib\screens\internships\archived_internships_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../models/internship_model.dart';

class ArchivedInternshipsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topLeft,
            colors: [AppColors.purplePrimary, AppColors.purpleLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppConstants.spaceL),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      SizedBox(width: AppConstants.spaceM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Archive',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completed internships',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('internships')
                        .where('studentId', isEqualTo: _auth.currentUser?.uid)
                        .where('isArchived', isEqualTo: true)
                        .orderBy('archivedDate', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final internships = snapshot.data!.docs
                          .map((doc) => Internship.fromFirestore(doc))
                          .toList();

                      if (internships.isEmpty) {
                        return _buildEmptyState(isDark);
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        itemCount: internships.length,
                        itemBuilder: (context, index) {
                          return _buildArchivedCard(context, internships[index], isDark);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedCard(BuildContext context, Internship internship, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      internship.company.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.company,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        internship.role,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.archive_outlined, size: 14, color: AppColors.mediumGray),
                      SizedBox(width: 4),
                      Text(
                        'Archived',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceM),
            if (internship.archivedDate != null)
              Text(
                'Archived on ${_formatDate(internship.archivedDate!)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mediumGray,
                ),
              ),
            SizedBox(height: AppConstants.spaceS),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _restoreInternship(context, internship),
                  icon: Icon(Icons.restore, size: 18),
                  label: Text('Restore'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.purplePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreInternship(BuildContext context, Internship internship) async {
    try {
      await _firestore.collection('internships').doc(internship.id).update({
        'isArchived': false,
        'archivedDate': null,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Internship restored'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 80,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: AppConstants.spaceL),
          Text(
            'No archived internships',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            'Completed internships will appear here',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}