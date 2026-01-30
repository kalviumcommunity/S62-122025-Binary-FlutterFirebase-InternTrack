// lib/screens/profile/mentorship_management_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../profile/widgets/mentor_card.dart';
import '../../app/app_routes.dart';

class MentorshipManagementScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topRight,
            colors: [AppColors.purplePrimary, AppColors.purpleLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _getMentorshipDataStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error loading mentors'),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final mentorCount = data['mentorCount'] as int;
                final primaryMentor = data['primaryMentor'] as Map<String, dynamic>?;
                final secondaryMentors = data['secondaryMentors'] as List<Map<String, dynamic>>;
                final pendingInvites = data['pendingInvites'] as List<Map<String, dynamic>>;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mentorship',
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '$mentorCount of 3 mentors',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Invite New Mentor Button
                            if (mentorCount < 3)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.inviteMentor);
                                  },
                                  icon: Icon(Icons.person_add_outlined, size: 20),
                                  label: Text('Invite New Mentor'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purplePrimary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              )
                            else
                              GlassContainer(
                                isDark: isDark,
                                padding: EdgeInsets.all(AppConstants.spaceM),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.mediumGray,
                                      size: 20,
                                    ),
                                    SizedBox(width: AppConstants.spaceM),
                                    Expanded(
                                      child: Text(
                                        'Maximum of 3 mentors reached',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Active Mentors Section
                            if (primaryMentor != null || secondaryMentors.isNotEmpty) ...[
                              Text(
                                'Active Mentors',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceM),

                              if (primaryMentor != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                  child: MentorCard(
                                    name: primaryMentor['name'],
                                    email: primaryMentor['email'],
                                    role: 'primary',
                                    isDark: isDark,
                                  ),
                                ),

                              ...secondaryMentors.map((mentor) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                  child: MentorCard(
                                    name: mentor['name'],
                                    email: mentor['email'],
                                    role: 'secondary',
                                    scope: mentor['scope'],
                                    isDark: isDark,
                                  ),
                                );
                              }).toList(),

                              SizedBox(height: AppConstants.spaceXL),
                            ],

                            // Pending Invitations Section
                            if (pendingInvites.isNotEmpty) ...[
                              Text(
                                'Pending Invitations',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceM),

                              ...pendingInvites.map((invite) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                  child: InviteStatusCard(
                                    mentorEmail: invite['mentorEmail'],
                                    status: invite['status'],
                                    createdAt: invite['createdAt'],
                                    isDark: isDark,
                                    onCancel: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Cancel Invitation'),
                                          content: Text('Are you sure you want to cancel this invitation?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text('Yes', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        await _firestore
                                            .collection('mentorInvites')
                                            .doc(invite['id'])
                                            .delete();
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Invitation cancelled'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ],

                            // Empty State
                            if (primaryMentor == null && 
                                secondaryMentors.isEmpty && 
                                pendingInvites.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: AppConstants.spaceXXL),
                                    Icon(
                                      Icons.supervisor_account_outlined,
                                      size: 80,
                                      color: AppColors.mediumGray.withOpacity(0.5),
                                    ),
                                    SizedBox(height: AppConstants.spaceL),
                                    Text(
                                      'No mentors yet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                      ),
                                    ),
                                    SizedBox(height: AppConstants.spaceS),
                                    Text(
                                      'Invite your first mentor to get started',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.mediumGray,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<Map<String, dynamic>> _getMentorshipDataStream(String uid) {
    return _firestore
        .collection('mentorStudentLinks')
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .asyncMap((linksSnapshot) async {
      try {
        // Get user data for primary mentor
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final primaryMentorId = userDoc.data()?['primaryMentorId'];

        // Get pending invites
        final pendingInvitesSnapshot = await _firestore
            .collection('mentorInvites')
            .where('studentId', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .get();

        final pendingInvites = pendingInvitesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'mentorEmail': data['mentorEmail'],
            'status': data['status'],
            'createdAt': (data['sentAt'] as Timestamp).toDate(),
          };
        }).toList();

        final mentorCount = linksSnapshot.docs.length;

        // Get primary mentor details
        Map<String, dynamic>? primaryMentor;
        if (primaryMentorId != null) {
          final mentorDoc = await _firestore.collection('users').doc(primaryMentorId).get();
          if (mentorDoc.exists) {
            primaryMentor = {
              'id': mentorDoc.id,
              'name': mentorDoc.data()?['displayName'] ?? 'Mentor',
              'email': mentorDoc.data()?['email'] ?? '',
            };
          }
        }

        // Get secondary mentors
        final secondaryMentors = <Map<String, dynamic>>[];
        for (var link in linksSnapshot.docs) {
          final mentorId = link.data()['mentorId'];
          if (mentorId != primaryMentorId) {
            final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
            if (mentorDoc.exists) {
              secondaryMentors.add({
                'id': mentorDoc.id,
                'name': mentorDoc.data()?['displayName'] ?? 'Mentor',
                'email': mentorDoc.data()?['email'] ?? '',
                'scope': link.data()['scope'] ?? 'general',
              });
            }
          }
        }

        return {
          'mentorCount': mentorCount,
          'primaryMentor': primaryMentor,
          'secondaryMentors': secondaryMentors,
          'pendingInvites': pendingInvites,
        };
      } catch (e) {
        print('Error in _getMentorshipDataStream: $e');
        return {
          'mentorCount': 0,
          'primaryMentor': null,
          'secondaryMentors': <Map<String, dynamic>>[],
          'pendingInvites': <Map<String, dynamic>>[],
        };
      }
    });
  }
}