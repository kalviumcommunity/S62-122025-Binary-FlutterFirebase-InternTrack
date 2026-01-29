// lib/providers/mentor_provider.dart
// FIXED: Now uses feedbackCycles instead of feedbackRequests
import 'package:flutter/material.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../models/feedback_cycle_model.dart';
import '../services/mentor_service.dart';
import '../services/email_service.dart';

class MentorProvider extends ChangeNotifier {
  final MentorService _mentorService = MentorService();
  final EmailService _emailService = EmailService();
  
  List<MentorStudentLink> _students = [];
  List<Internship> _selectedStudentInternships = [];
  List<FeedbackCycle> _pendingCycles = [];
  MentorStudentLink? _selectedStudent;
  bool _isLoading = false;
  String? _error;

  List<MentorStudentLink> get students => _students;
  List<Internship> get selectedStudentInternships => _selectedStudentInternships;
  List<FeedbackCycle> get requests => _pendingCycles; // Keep same getter name for compatibility
  MentorStudentLink? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInternships => _selectedStudentInternships.length;

  /// Initialize pending feedback requests for mentor
  void initializeRequests(String mentorId) {
    print('MentorProvider: Initializing requests for mentor: $mentorId');
    
    _mentorService.getMentorPendingCycles(mentorId).listen(
      (cycles) {
        print('MentorProvider: Received ${cycles.length} pending cycles');
        _pendingCycles = cycles;
        notifyListeners();
      },
      onError: (error) {
        print('MentorProvider ERROR in requests stream: $error');
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// Initialize mentor's students stream
  void initializeStudentsStream(String mentorId) {
    _isLoading = true;
    notifyListeners();

    _mentorService.getStudentsStream(mentorId).listen(
      (students) {
        _students = students;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Select a student and load their internships
  void selectStudent(MentorStudentLink student) {
    _selectedStudent = student;
    notifyListeners();

    _mentorService.getStudentInternshipsStream(student.studentId).listen(
      (internships) {
        _selectedStudentInternships = internships;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// Submit feedback for a cycle
  Future<void> submitFeedback({
    required String cycleId,
    required String feedback,
    String? nextStep,
  }) async {
    try {
      await _mentorService.submitFeedback(
        cycleId: cycleId,
        feedback: feedback,
        nextStep: nextStep,
      );
      // Cycles list will auto-update via stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Send mentor invitation
  Future<bool> sendInvitation({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String mentorEmail,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _mentorService.sendInvitation(
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        mentorEmail: mentorEmail,
      );

      final emailSent = await _emailService.sendMentorInvitation(
        mentorEmail: mentorEmail,
        studentName: studentName,
        studentEmail: studentEmail,
      );

      _isLoading = false;
      notifyListeners();
      
      return emailSent;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear selected student
  void clearSelectedStudent() {
    _selectedStudent = null;
    _selectedStudentInternships = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}