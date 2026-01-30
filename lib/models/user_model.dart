import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student' or 'mentor'
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  // Resume fields
  final String? resumeUrl;
  final String? resumeFileName;
  final DateTime? resumeUpdatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'student',
    required this.createdAt,
    this.lastLoginAt,
    this.resumeUrl,
    this.resumeFileName,
    this.resumeUpdatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'resumeUpdatedAt': resumeUpdatedAt != null ? Timestamp.fromDate(resumeUpdatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] as Timestamp).toDate() 
          : null,
      resumeUrl: map['resumeUrl'] as String?,
      resumeFileName: map['resumeFileName'] as String?,
      resumeUpdatedAt: map['resumeUpdatedAt'] != null
          ? (map['resumeUpdatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? resumeUrl,
    String? resumeFileName,
    DateTime? resumeUpdatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      resumeUpdatedAt: resumeUpdatedAt ?? this.resumeUpdatedAt,
    );
  }

  // Check if user has uploaded resume
  bool get hasResume => resumeUrl != null && resumeUrl!.isNotEmpty;
}