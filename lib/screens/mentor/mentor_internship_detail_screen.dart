// lib/screens/mentor/mentor_internship_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../models/internship_model.dart';

class MentorInternshipDetailScreen extends StatelessWidget {
  final Internship internship;

  const MentorInternshipDetailScreen({Key? key, required this.internship}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topRight,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.blueLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_outlined, size: 16, color: AppColors.bluePrimary),
                                  SizedBox(width: 6),
                                  Text(
                                    'View Only',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.bluePrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppConstants.spaceL),

                        GlassContainer(
                          isDark: isDark,
                          padding: EdgeInsets.all(AppConstants.spaceL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.bluePrimary, AppColors.blueLight],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        internship.company.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
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
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          internship.role,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.spaceM),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildStatusBadge(internship.status),
                                  _buildPriorityBadge(internship.priority),
                                  if (internship.location != null)
                                    _buildInfoChip(Icons.location_on_outlined, internship.location!),
                                  if (internship.salary != null)
                                    _buildInfoChip(Icons.attach_money_rounded, internship.salary!),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppConstants.spaceL),

                        if (internship.description != null) ...[
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),
                          GlassContainer(
                            isDark: isDark,
                            padding: EdgeInsets.all(AppConstants.spaceM),
                            child: Text(
                              internship.description!,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceL),
                        ],

                        if (internship.timeline.isNotEmpty) ...[
                          Text(
                            'Timeline',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),
                          _buildTimeline(isDark),
                          SizedBox(height: AppConstants.spaceL),
                        ],

                        if (internship.reflectionNotes != null && internship.reflectionNotes!.isNotEmpty) ...[
                          Text(
                            'Student Reflections',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),
                          GlassContainer(
                            isDark: isDark,
                            padding: EdgeInsets.all(AppConstants.spaceM),
                            child: Text(
                              internship.reflectionNotes!,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceL),
                        ],

                        if (internship.skillsGained.isNotEmpty) ...[
                          Text(
                            'Skills Gained',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),
                          GlassContainer(
                            isDark: isDark,
                            padding: EdgeInsets.all(AppConstants.spaceM),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: internship.skillsGained.map((skill) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.bluePrimary, AppColors.blueLight],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceXL),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isDark) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        children: internship.timeline.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == internship.timeline.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.bluePrimary, AppColors.blueLight],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: AppColors.mediumGray.withOpacity(0.3),
                    ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                        ),
                      ),
                      if (event.description != null) ...[
                        SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        _formatDate(event.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(InternshipStatus status) {
    Color color;
    switch (status) {
      case InternshipStatus.applied:
        color = Colors.blue;
        break;
      case InternshipStatus.interviewing:
        color = Colors.orange;
        break;
      case InternshipStatus.offered:
        color = Colors.green;
        break;
      case InternshipStatus.accepted:
        color = AppColors.bluePrimary;
        break;
      case InternshipStatus.rejected:
        color = Colors.red;
        break;
      case InternshipStatus.archived:
        color = AppColors.mediumGray;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    Color color;
    String label;
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        label = 'High Priority';
        break;
      case Priority.medium:
        color = Colors.orange;
        label = 'Medium Priority';
        break;
      case Priority.low:
        color = Colors.green;
        label = 'Low Priority';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mediumGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mediumGray),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(InternshipStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        ).trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}