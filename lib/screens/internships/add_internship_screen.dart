import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/purple_button.dart';
import '../../core/widgets/internship_widgets.dart'; // FIXED: Corrected import
import '../../models/internship_model.dart';
import '../../providers/internship_provider.dart';
import 'dart:ui';

class AddInternshipScreen extends StatefulWidget {
  @override
  State<AddInternshipScreen> createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  InternshipStatus _selectedStatus = InternshipStatus.applied;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveInternship() async {
    if (!_formKey.currentState!.validate()) return;

    final internship = Internship(
      id: '',
      studentId: _auth.currentUser!.uid,
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      appliedDate: DateTime.now(),
      deadline: _selectedDeadline,
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      location: _locationController.text.trim().isNotEmpty 
          ? _locationController.text.trim() 
          : null,
      salary: _salaryController.text.trim().isNotEmpty 
          ? _salaryController.text.trim() 
          : null,
      timeline: [
        TimelineEvent(
          date: DateTime.now(),
          title: 'Applied to ${_companyController.text.trim()}',
          description: 'Application submitted for ${_roleController.text.trim()}',
          type: 'applied',
        ),
      ],
    );

    final success = await context.read<InternshipProvider>().addInternship(internship);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Internship added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<InternshipProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<InternshipProvider>().isLoading;

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
                            'Add Internship',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Track a new application',
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
                            children: InternshipStatus.values
                                .where((s) => s != InternshipStatus.archived)
                                .map((status) {
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
                                    InternshipHelpers.getStatusLabel(status),
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
                                          InternshipHelpers.getPriorityLabel(priority),
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
                            'Deadline (Optional)',
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
                                initialDate: DateTime.now().add(Duration(days: 7)),
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
                                        : InternshipHelpers.formatDate(_selectedDeadline!),
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
                                'Description (Optional)',
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
                                      hintText: 'Add any notes or details about this internship...',
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
                            text: 'Add Internship',
                            icon: Icons.check_rounded,
                            onPressed: _saveInternship,
                            isLoading: isLoading,
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
}