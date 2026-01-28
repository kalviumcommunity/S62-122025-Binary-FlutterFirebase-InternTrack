// internship_provider.dart
import 'package:flutter/material.dart';
import '../models/internship_model.dart';
import '../services/internship_service.dart';

class InternshipProvider extends ChangeNotifier {
  final InternshipService _internshipService = InternshipService();
  
  List<Internship> _internships = [];
  List<Internship> _archivedInternships = [];
  bool _isLoading = false;
  String? _error;

  List<Internship> get internships => _internships;
  List<Internship> get archivedInternships => _archivedInternships;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get internships count by status
  int getCountByStatus(InternshipStatus status) {
    return _internships.where((i) => i.status == status).length;
  }

  // Get upcoming deadlines
  List<Internship> getUpcomingDeadlines() {
    return _internships
        .where((i) => i.deadline != null && i.deadline!.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }

  // Initialize internships stream
  void initializeInternshipsStream(String studentId) {
    _isLoading = true;
    notifyListeners();

    _internshipService.getInternshipsStream(studentId).listen(
      (internships) {
        _internships = internships;
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

  // Initialize archived internships stream
  void initializeArchivedStream(String studentId) {
    _internshipService.getArchivedInternshipsStream(studentId).listen(
      (internships) {
        _archivedInternships = internships;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Add internship
  Future<bool> addInternship(Internship internship) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _internshipService.addInternship(internship);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update internship
  Future<bool> updateInternship(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _internshipService.updateInternship(id, updates);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete internship
  Future<bool> deleteInternship(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _internshipService.deleteInternship(id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Archive internship
  Future<bool> archiveInternship(String id) async {
    try {
      await _internshipService.archiveInternship(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Restore internship
  Future<bool> restoreInternship(String id) async {
    try {
      await _internshipService.restoreInternship(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update reflection notes
  Future<bool> updateReflectionNotes(String id, String notes) async {
    try {
      await _internshipService.updateReflectionNotes(id, notes);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update learning outcomes
  Future<bool> updateLearningOutcomes(String id, String outcomes, List<String> skills) async {
    try {
      await _internshipService.updateLearningOutcomes(id, outcomes, skills);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add timeline event
  Future<bool> addTimelineEvent(String id, TimelineEvent event, List<TimelineEvent> existingTimeline) async {
    try {
      await _internshipService.addTimelineEvent(id, event, existingTimeline);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}