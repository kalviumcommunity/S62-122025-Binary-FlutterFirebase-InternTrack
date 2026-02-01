// lib/screens/mentor/widget/mentor_private_notes.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../services/mentor_notes_service.dart';
import '../../../models/mentor_notes_model.dart';
import 'dart:async';

class MentorPrivateNotes extends StatefulWidget {
  final String studentId;
  final String? internshipId;
  final bool isDark;

  const MentorPrivateNotes({
    Key? key,
    required this.studentId,
    this.internshipId,
    required this.isDark,
  }) : super(key: key);

  @override
  State<MentorPrivateNotes> createState() => _MentorPrivateNotesState();
}

class _MentorPrivateNotesState extends State<MentorPrivateNotes> {
  final MentorNotesService _notesService = MentorNotesService();
  final TextEditingController _controller = TextEditingController();
  Timer? _saveTimer;
  bool _isSaving = false;
  String? _lastSavedContent;

  @override
  void dispose() {
    _controller.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Cancel previous timer
    _saveTimer?.cancel();

    // Start new timer for auto-save (2 seconds after user stops typing)
    _saveTimer = Timer(Duration(seconds: 2), () {
      if (value.trim() != _lastSavedContent) {
        _saveNote(value.trim());
      }
    });
  }

  Future<void> _saveNote(String content) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final mentorId = FirebaseAuth.instance.currentUser!.uid;

      if (widget.internshipId != null) {
        // Save internship note
        await _notesService.saveInternshipNote(
          mentorId: mentorId,
          studentId: widget.studentId,
          internshipId: widget.internshipId!,
          content: content,
        );
      } else {
        // Save student note
        await _notesService.saveStudentNote(
          mentorId: mentorId,
          studentId: widget.studentId,
          content: content,
        );
      }

      _lastSavedContent = content;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Note saved'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<MentorNote?>(
      stream: widget.internshipId != null
          ? _notesService.getInternshipNote(
              mentorId: mentorId,
              internshipId: widget.internshipId!,
            )
          : _notesService.getStudentNote(
              mentorId: mentorId,
              studentId: widget.studentId,
            ),
      builder: (context, snapshot) {
        // Initialize controller with existing note
        if (snapshot.hasData && _controller.text.isEmpty) {
          _controller.text = snapshot.data!.content;
          _lastSavedContent = snapshot.data!.content;
        }

        return GlassContainer(
          isDark: widget.isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.bluePrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Private Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                  ),
                  if (_isSaving)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Only visible to you • Auto-saves',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
              SizedBox(height: AppConstants.spaceM),
              
              TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                maxLines: 6,
                style: TextStyle(
                  color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: widget.internshipId != null
                      ? 'Notes about this specific internship application...'
                      : 'General notes about this student...',
                  hintStyle: TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.bluePrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}