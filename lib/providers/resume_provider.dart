import 'package:flutter/material.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/resume_service.dart';
import '../models/resume_model.dart';

class ResumeProvider extends ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ResumeService _resumeService = ResumeService();

  ResumeModel? _resume;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  ResumeModel? get resume => _resume;
  String? get resumeUrl => _resume?.cloudinaryUrl;
  String? get resumeFileName => _resume?.fileName;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  // Initialize resume stream
  void initializeResumeStream(String userId) {
    _resumeService.streamResume(userId).listen(
      (resume) {
        _resume = resume;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Upload resume
  Future<bool> uploadResume(File file, String userId) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      notifyListeners();

      // Get original filename
      final originalFileName = file.path.split('/').last;
      
      // Check file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        _error = 'File size must be less than 10MB';
        _isUploading = false;
        notifyListeners();
        return false;
      }

      // Check file extension
      if (!originalFileName.toLowerCase().endsWith('.pdf')) {
        _error = 'Only PDF files are allowed';
        _isUploading = false;
        notifyListeners();
        return false;
      }

      _uploadProgress = 0.2;
      notifyListeners();

      // Delete old resume if exists
      if (_resume != null) {
        await _cloudinaryService.deleteResume(_resume!.publicId);
        await _resumeService.deleteResume(userId, _resume!.id);
      }

      _uploadProgress = 0.4;
      notifyListeners();

      // Upload to Cloudinary
      final resumeUrl = await _cloudinaryService.uploadResume(file, userId);
      
      if (resumeUrl == null) {
        _error = 'Failed to upload resume';
        _isUploading = false;
        _uploadProgress = 0.0;
        notifyListeners();
        return false;
      }

      _uploadProgress = 0.7;
      notifyListeners();

      // Extract public ID from URL
      final publicId = _cloudinaryService.getPublicIdFromUrl(resumeUrl);

      // Create resume model
      final resume = ResumeModel(
        id: '${userId}_resume',
        userId: userId,
        fileName: originalFileName, // PRESERVE ORIGINAL NAME
        cloudinaryUrl: resumeUrl,
        publicId: publicId,
        fileSizeBytes: fileSize,
        uploadedAt: DateTime.now(),
      );

      // Save to Firestore
      await _resumeService.saveResume(resume);

      _resume = resume;
      _uploadProgress = 1.0;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  // Delete resume
  Future<bool> deleteResume(String userId) async {
    try {
      if (_resume == null) return false;

      _isUploading = true;
      _error = null;
      notifyListeners();

      // Delete from Cloudinary
      await _cloudinaryService.deleteResume(_resume!.publicId);

      // Delete from Firestore
      await _resumeService.deleteResume(userId, _resume!.id);

      _resume = null;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get display filename (shows original filename, not Cloudinary's)
  String getFileNameFromUrl(String url) {
    // If we have the resume model, use the original filename
    if (_resume != null && _resume!.fileName.isNotEmpty) {
      return _resume!.fileName;
    }
    
    // Fallback: parse from URL
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.last;
    } catch (e) {
      return 'resume.pdf';
    }
  }
}