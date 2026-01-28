// lib/screens/internships/edit_internship_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/purple_button.dart';
import '../../models/internship_model.dart';
import 'dart:ui';

class EditInternshipScreen extends StatefulWidget {
  final Internship internship;

  const EditInternshipScreen({Key? key, required this.internship}) : super(key: key);

  @override
  State<EditInternshipScreen> createState() => _EditInternshipScreenState();
}

class _EditInternshipScreenState extends State<EditInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _salaryController;

  late InternshipStatus _selectedStatus;
  late Priority _selectedPriority;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.internship.company);
    _roleController = TextEditingController(text: widget.internship.role);
    _descriptionController = TextEditingController(text: widget.internship.description ?? '');
    _locationController = TextEditingController(text: widget.internship.location ?? '');
    _salaryController = TextEditingController(text: widget.internship.salary ?? '');
    
    _selectedStatus = widget.internship.status;
    _selectedPriority = widget.internship.priority;
    _selectedDeadline = widget.internship.deadline;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _updateInternship() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'company': _companyController.text.trim(),
        'role': _roleController.text.trim(),
        'status': _selectedStatus.toString().split('.').last,
        'priority': _selectedPriority.toString().split('.').last,
        'deadline': _selectedDeadline != null ? Timestamp.fromDate(_selectedDeadline!) : null,
        'description': _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        'location': _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        'salary': _salaryController.text.trim().isNotEmpty ? _salaryController.text.trim() : null,
      };

      // Add timeline event if status changed
      if (_selectedStatus != widget.internship.status) {
        final timeline = List<Map<String, dynamic>>.from(
          widget.internship.timeline.map((e) => e.toMap()),
        );
        timeline.add(TimelineEvent(
          date: DateTime.now(),
          title: 'Status changed to ${_getStatusLabel(_selectedStatus)}',
          type: 'update',
        ).toMap());
        updates['timeline'] = timeline;
      }

      await _firestore.collection('internships').doc(widget.internship.id).update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Internship updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                            'Edit Internship',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Update application details',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassTextField(
                            label: 'Company Name *',
                            hint: 'Enter company name',
                            controller: _companyController,
                            isDark: isDark,
                            prefixIcon: Icons.business_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter company name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          GlassTextField(
                            label: 'Role / Position *',
                            hint: 'Enter role or position',
                            controller: _roleController,
                            isDark: isDark,
                            prefixIcon: Icons.work_outline_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter role';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          GlassTextField(
                            label: 'Location',
                            hint: 'Enter location (optional)',
                            controller: _locationController,
                            isDark: isDark,
                            prefixIcon: Icons.location_on_outlined,
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          GlassTextField(
                            label: 'Salary / Stipend',
                            hint: 'Enter salary or stipend (optional)',
                            controller: _salaryController,
                            isDark: isDark,
                            prefixIcon: Icons.attach_money_rounded,
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceS),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: InternshipStatus.values.where((s) => s != InternshipStatus.archived).map((status) {
                              final isSelected = _selectedStatus == status;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedStatus = status),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : isDark
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    _getStatusLabel(status),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : isDark
                                              ? AppColors.pureWhite
                                              : AppColors.pureBlack,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceS),
                          Row(
                            children: Priority.values.map((priority) {
                              final isSelected = _selectedPriority == priority;
                              Color priorityColor;
                              switch (priority) {
                                case Priority.high:
                                  priorityColor = Colors.red;
                                  break;
                                case Priority.medium:
                                  priorityColor = Colors.orange;
                                  break;
                                case Priority.low:
                                  priorityColor = Colors.green;
                                  break;
                              }
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: priority != Priority.low ? 8 : 0),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPriority = priority),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? priorityColor.withOpacity(0.2)
                                            : isDark
                                                ? Colors.white.withOpacity(0.1)
                                                : Colors.black.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? priorityColor
                                              : isDark
                                                  ? Colors.white.withOpacity(0.2)
                                                  : Colors.black.withOpacity(0.1),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getPriorityLabel(priority),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? priorityColor
                                                : isDark
                                                    ? AppColors.pureWhite
                                                    : AppColors.pureBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          Text(
                            'Deadline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceS),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDeadline ?? DateTime.now().add(Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _selectedDeadline = date);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.mediumGray,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    _selectedDeadline == null
                                        ? 'Select deadline'
                                        : _formatDate(_selectedDeadline!),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _selectedDeadline == null
                                          ? AppColors.mediumGray
                                          : isDark
                                              ? AppColors.pureWhite
                                              : AppColors.pureBlack,
                                    ),
                                  ),
                                  if (_selectedDeadline != null) ...[
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedDeadline = null),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppColors.mediumGray,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 4,
                                    style: TextStyle(
                                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add any notes or details...',
                                      hintStyle: TextStyle(color: AppColors.mediumGray),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.1),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                        borderSide: BorderSide(
                                          color: AppColors.purplePrimary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppConstants.spaceXL),

                          PurpleButton(
                            text: 'Update Internship',
                            icon: Icons.check_rounded,
                            onPressed: _updateInternship,
                            isLoading: _isLoading,
                            width: double.infinity,
                          ),

                          SizedBox(height: AppConstants.spaceL),
                        ],
                      ),
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

  String _getStatusLabel(InternshipStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        ).trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getPriorityLabel(Priority priority) {
    return priority.toString().split('.').last[0].toUpperCase() +
        priority.toString().split('.').last.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}