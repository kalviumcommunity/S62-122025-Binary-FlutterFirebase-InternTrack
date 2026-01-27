// lib/providers/mentor_provider.dart
import 'package:flutter/material.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../services/mentor_service.dart';
import '../services/email_service.dart';

class MentorProvider extends ChangeNotifier {
  final MentorService _mentorService = MentorService();
  final EmailService _emailService = EmailService();
  
  List<MentorStudentLink> _students = [];
  List<Internship> _selectedStudentInternships = [];
  MentorStudentLink? _selectedStudent;
  bool _isLoading = false;
  String? _error;

  List<MentorStudentLink> get students => _students;
  List<Internship> get selectedStudentInternships => _selectedStudentInternships;
  MentorStudentLink? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize mentor's students stream
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

  // Select a student and load their internships
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

  // Send mentor invitation
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

      // Send invitation to Firestore
      await _mentorService.sendInvitation(
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        mentorEmail: mentorEmail,
      );

      // Send email notification
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

  // Clear selected student
  void clearSelectedStudent() {
    _selectedStudent = null;
    _selectedStudentInternships = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}