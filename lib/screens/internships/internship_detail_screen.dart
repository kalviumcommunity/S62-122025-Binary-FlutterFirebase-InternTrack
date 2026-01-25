import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../models/internship_model.dart';
import '../../app/app_routes.dart';
import 'dart:ui';

class InternshipDetailScreen extends StatefulWidget {
  final Internship internship;

  const InternshipDetailScreen({Key? key, required this.internship}) : super(key: key);

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _learningController = TextEditingController();
  final List<String> _availableSkills = [
    'Communication',
    'Leadership',
    'Problem Solving',
    'Team Work',
    'Time Management',
    'Critical Thinking',
    'Adaptability',
    'Technical Skills',
    'Data Analysis',
    'Project Management',
  ];
  List<String> _selectedSkills = [];
  bool _isEditingReflection = false;
  bool _isEditingLearning = false;

  @override
  void initState() {
    super.initState();
    _reflectionController.text = widget.internship.reflectionNotes ?? '';
    _learningController.text = widget.internship.learningOutcomes ?? '';
    _selectedSkills = List.from(widget.internship.skillsGained);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _learningController.dispose();
    super.dispose();
  }

  Future<void> _deleteInternship() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('internships').doc(widget.internship.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Internship deleted'), backgroundColor: Colors.red),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _archiveInternship() async {
    try {
      await _firestore.collection('internships').doc(widget.internship.id).update({
        'isArchived': true,
        'archivedDate': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Internship archived'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveReflection() async {
    try {
      await _firestore.collection('internships').doc(widget.internship.id).update({
        'reflectionNotes': _reflectionController.text.trim(),
      });
      setState(() => _isEditingReflection = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reflection saved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveLearning() async {
    try {
      await _firestore.collection('internships').doc(widget.internship.id).update({
        'learningOutcomes': _learningController.text.trim(),
        'skillsGained': _selectedSkills,
      });
      setState(() => _isEditingLearning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Learning outcomes saved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: CustomScrollView(
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
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.editInternship,
                                  arguments: {'internship': widget.internship},
                                );
                              },
                              icon: Icon(Icons.edit_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            SizedBox(width: 8),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert_rounded),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: _archiveInternship,
                                  child: Row(
                                    children: [
                                      Icon(Icons.archive_outlined, size: 20),
                                      SizedBox(width: 12),
                                      Text('Archive'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: _deleteInternship,
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: AppConstants.spaceL),

                        // Company Header
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
                                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.internship.company.substring(0, 1).toUpperCase(),
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
                                          widget.internship.company,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          widget.internship.role,
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
                                  _buildStatusBadge(widget.internship.status),
                                  _buildPriorityBadge(widget.internship.priority),
                                  if (widget.internship.location != null)
                                    _buildInfoChip(Icons.location_on_outlined, widget.internship.location!),
                                  if (widget.internship.salary != null)
                                    _buildInfoChip(Icons.attach_money_rounded, widget.internship.salary!),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppConstants.spaceL),

                        // Timeline
                        if (widget.internship.timeline.isNotEmpty) ...[
                          Text(
                            'Timeline',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),
                          _buildTimeline(isDark),
                          SizedBox(height: AppConstants.spaceL),
                        ],

                        // Reflection Notes
                        Text(
                          'Personal Reflections',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: AppConstants.spaceM),
                        _buildReflectionSection(isDark),

                        SizedBox(height: AppConstants.spaceL),

                        // Learning Outcomes
                        Text(
                          'Learning & Growth',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: AppConstants.spaceM),
                        _buildLearningSection(isDark),

                        SizedBox(height: AppConstants.spaceXL),
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
        children: widget.internship.timeline.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == widget.internship.timeline.length - 1;
          
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
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
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

  Widget _buildReflectionSection(bool isDark) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'What did you learn from this experience?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
              if (!_isEditingReflection)
                IconButton(
                  onPressed: () => setState(() => _isEditingReflection = true),
                  icon: Icon(Icons.edit_outlined, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: AppConstants.spaceM),
          if (_isEditingReflection) ...[
            TextField(
              controller: _reflectionController,
              maxLines: 6,
              style: TextStyle(
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Write your thoughts and reflections...',
                hintStyle: TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: AppConstants.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _reflectionController.text = widget.internship.reflectionNotes ?? '';
                      _isEditingReflection = false;
                    });
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveReflection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplePrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ] else ...[
            Text(
              _reflectionController.text.isEmpty
                  ? 'No reflections added yet. Tap edit to add your thoughts.'
                  : _reflectionController.text,
              style: TextStyle(
                fontSize: 15,
                color: _reflectionController.text.isEmpty
                    ? AppColors.mediumGray
                    : isDark
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
                fontStyle: _reflectionController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearningSection(bool isDark) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Skills & Learning Outcomes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
              ),
              if (!_isEditingLearning)
                IconButton(
                  onPressed: () => setState(() => _isEditingLearning = true),
                  icon: Icon(Icons.edit_outlined, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: AppConstants.spaceM),
          
          // Skills
          Text(
            'Skills Gained',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          if (_isEditingLearning) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSkills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSkills.remove(skill);
                      } else {
                        _selectedSkills.add(skill);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [AppColors.purplePrimary, AppColors.purpleLight],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.mediumGray,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            if (_selectedSkills.isEmpty)
              Text(
                'No skills added yet',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedSkills.map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
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
          ],
          
          SizedBox(height: AppConstants.spaceM),
          
          // Learning Outcomes
          Text(
            'What I Learned',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          if (_isEditingLearning) ...[
            TextField(
              controller: _learningController,
              maxLines: 4,
              style: TextStyle(
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Describe your learning outcomes...',
                hintStyle: TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: AppConstants.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _learningController.text = widget.internship.learningOutcomes ?? '';
                      _selectedSkills = List.from(widget.internship.skillsGained);
                      _isEditingLearning = false;
                    });
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveLearning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplePrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ] else ...[
            Text(
              _learningController.text.isEmpty
                  ? 'No learning outcomes added yet'
                  : _learningController.text,
              style: TextStyle(
                fontSize: 14,
                color: _learningController.text.isEmpty
                    ? AppColors.mediumGray
                    : isDark
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
                fontStyle: _learningController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeleteDialog() {
    return AlertDialog(
      title: Text('Delete Internship'),
      content: Text('Are you sure you want to delete this internship? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
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
        color = AppColors.purplePrimary;
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