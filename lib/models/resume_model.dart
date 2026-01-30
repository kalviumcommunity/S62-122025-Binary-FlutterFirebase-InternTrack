import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {
  final String id;
  final String userId;
  final String fileName; // Original filename from user
  final String cloudinaryUrl;
  final String publicId; // Cloudinary public ID
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final DateTime? lastModified;

  ResumeModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.cloudinaryUrl,
    required this.publicId,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.lastModified,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'cloudinaryUrl': cloudinaryUrl,
      'publicId': publicId,
      'fileSizeBytes': fileSizeBytes,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'lastModified': lastModified != null ? Timestamp.fromDate(lastModified!) : null,
    };
  }

  // Create from Firestore document
  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fileName: map['fileName'] ?? 'resume.pdf',
      cloudinaryUrl: map['cloudinaryUrl'] ?? '',
      publicId: map['publicId'] ?? '',
      fileSizeBytes: map['fileSizeBytes'] ?? 0,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      lastModified: map['lastModified'] != null 
          ? (map['lastModified'] as Timestamp).toDate() 
          : null,
    );
  }

  // Create from Firestore snapshot
  factory ResumeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResumeModel.fromMap(data);
  }

  // Get file size in human-readable format
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Copy with method for updates
  ResumeModel copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? cloudinaryUrl,
    String? publicId,
    int? fileSizeBytes,
    DateTime? uploadedAt,
    DateTime? lastModified,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      cloudinaryUrl: cloudinaryUrl ?? this.cloudinaryUrl,
      publicId: publicId ?? this.publicId,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}