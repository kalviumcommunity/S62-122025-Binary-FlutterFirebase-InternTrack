// lib/providers/mentor_provider.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../models/feedback_cycle_model.dart';
import '../services/mentor_service.dart';
import '../services/email_service.dart';

class MentorProvider extends ChangeNotifier {
  final MentorService _mentorService = MentorService();
  final EmailService _emailService = EmailService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<MentorStudentLink> _students = [];
  List<Internship> _selectedStudentInternships = [];
  List<FeedbackCycle> _allCycles = []; // CHANGED: Store ALL cycles, not just pending
  int _totalFeedbackGiven = 0;
  MentorStudentLink? _selectedStudent;
  bool _isLoading = false;
  String? _error;

  List<MentorStudentLink> get students => _students;
  List<Internship> get selectedStudentInternships => _selectedStudentInternships;
  List<FeedbackCycle> get requests => _allCycles; // CHANGED: Return all cycles
  MentorStudentLink? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInternships => _selectedStudentInternships.length;

  // Dashboard statistics
  int get totalStudents => _students.length;
  int get pendingRequestsCount => _allCycles.where((c) => c.status == 'pending').length;
  
  int _highPriorityInternshipsCount = 0;
  int get highPriorityInternshipsCount => _highPriorityInternshipsCount;
  
  DateTime? get lastRequestTime {
    final pendingCycles = _allCycles.where((c) => c.status == 'pending').toList();
    if (pendingCycles.isEmpty) return null;
    return pendingCycles
        .map((c) => c.requestedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
  
  int get totalFeedbackGiven => _totalFeedbackGiven;

  /// Initialize ALL feedback cycles for mentor (not just pending!)
  void initializeRequests(String mentorId) {
    print('🔄 MentorProvider: Initializing ALL requests for mentor: $mentorId');
    
    // CRITICAL FIX: Load ALL cycles, not just pending ones
    _firestore
        .collection('feedbackCycles')
        .where('mentorId', isEqualTo: mentorId)
        // Removed status filter - get ALL cycles
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            print('📦 Received ${snapshot.docs.length} total feedback cycles');
            _allCycles = snapshot.docs
                .map((doc) => FeedbackCycle.fromFirestore(doc))
                .toList();
            
            // Debug: Print what we got
            for (var cycle in _allCycles) {
              print('  - ${cycle.id}: status=${cycle.status}, seenByStudent=${cycle.seenByStudent}');
            }
            
            notifyListeners();
          },
          onError: (error) {
            print('❌ MentorProvider ERROR in cycles stream: $error');
            _error = error.toString();
            notifyListeners();
          },
        );

    // Load total feedback count
    _loadFeedbackCount(mentorId);
    
    // Load high-priority internships count
    _loadHighPriorityInternships(mentorId);
  }

  /// Load high-priority internships count across all students
  Future<void> _loadHighPriorityInternships(String mentorId) async {
    try {
      final studentSnapshot = await _firestore
          .collection('mentorStudentLinks')
          .where('mentorId', isEqualTo: mentorId)
          .get();
      
      final studentIds = studentSnapshot.docs
          .map((doc) => doc.data()['studentId'] as String)
          .toList();
      
      if (studentIds.isEmpty) {
        _highPriorityInternshipsCount = 0;
        notifyListeners();
        return;
      }
      
      int count = 0;
      for (final studentId in studentIds) {
        final internshipSnapshot = await _firestore
            .collection('internships')
            .where('studentId', isEqualTo: studentId)
            .where('priority', isEqualTo: 'high')
            .where('isArchived', isEqualTo: false)
            .get();
        
        count += internshipSnapshot.docs.length;
      }
      
      _highPriorityInternshipsCount = count;
      notifyListeners();
    } catch (e) {
      print('MentorProvider ERROR loading high-priority internships: $e');
    }
  }

  /// Load actual feedback count from Firestore
  Future<void> _loadFeedbackCount(String mentorId) async {
    try {
      final snapshot = await _firestore
          .collection('feedbackCycles')
          .where('mentorId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'completed')
          .get();
      
      _totalFeedbackGiven = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      print('MentorProvider ERROR loading feedback count: $e');
    }
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
      
      _totalFeedbackGiven++;
      notifyListeners();
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
      rethrow;
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