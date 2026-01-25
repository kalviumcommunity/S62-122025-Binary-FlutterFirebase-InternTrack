import 'package:cloud_firestore/cloud_firestore.dart';

enum InternshipStatus {
  applied,
  interviewing,
  offered,
  accepted,
  rejected,
  archived
}

enum Priority {
  high,
  medium,
  low
}

class Internship {
  final String id;
  final String studentId;
  final String company;
  final String role;
  final InternshipStatus status;
  final Priority priority;
  final DateTime? deadline;
  final DateTime appliedDate;
  final String? description;
  final String? location;
  final String? salary;
  final List<String> skillsGained;
  final String? reflectionNotes;
  final String? learningOutcomes;
  final List<TimelineEvent> timeline;
  final bool isArchived;
  final DateTime? archivedDate;

  Internship({
    required this.id,
    required this.studentId,
    required this.company,
    required this.role,
    required this.status,
    this.priority = Priority.medium,
    this.deadline,
    required this.appliedDate,
    this.description,
    this.location,
    this.salary,
    this.skillsGained = const [],
    this.reflectionNotes,
    this.learningOutcomes,
    this.timeline = const [],
    this.isArchived = false,
    this.archivedDate,
  });

  factory Internship.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Internship(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      status: InternshipStatus.values.firstWhere(
        (e) => e.toString() == 'InternshipStatus.${data['status']}',
        orElse: () => InternshipStatus.applied,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == 'Priority.${data['priority']}',
        orElse: () => Priority.medium,
      ),
      deadline: data['deadline'] != null 
          ? (data['deadline'] as Timestamp).toDate() 
          : null,
      appliedDate: (data['appliedDate'] as Timestamp).toDate(),
      description: data['description'],
      location: data['location'],
      salary: data['salary'],
      skillsGained: List<String>.from(data['skillsGained'] ?? []),
      reflectionNotes: data['reflectionNotes'],
      learningOutcomes: data['learningOutcomes'],
      timeline: (data['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEvent.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      isArchived: data['isArchived'] ?? false,
      archivedDate: data['archivedDate'] != null 
          ? (data['archivedDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'company': company,
      'role': role,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'description': description,
      'location': location,
      'salary': salary,
      'skillsGained': skillsGained,
      'reflectionNotes': reflectionNotes,
      'learningOutcomes': learningOutcomes,
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'isArchived': isArchived,
      'archivedDate': archivedDate != null ? Timestamp.fromDate(archivedDate!) : null,
    };
  }

  Internship copyWith({
    String? id,
    String? studentId,
    String? company,
    String? role,
    InternshipStatus? status,
    Priority? priority,
    DateTime? deadline,
    DateTime? appliedDate,
    String? description,
    String? location,
    String? salary,
    List<String>? skillsGained,
    String? reflectionNotes,
    String? learningOutcomes,
    List<TimelineEvent>? timeline,
    bool? isArchived,
    DateTime? archivedDate,
  }) {
    return Internship(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      appliedDate: appliedDate ?? this.appliedDate,
      description: description ?? this.description,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      skillsGained: skillsGained ?? this.skillsGained,
      reflectionNotes: reflectionNotes ?? this.reflectionNotes,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      timeline: timeline ?? this.timeline,
      isArchived: isArchived ?? this.isArchived,
      archivedDate: archivedDate ?? this.archivedDate,
    );
  }
}

class TimelineEvent {
  final DateTime date;
  final String title;
  final String? description;
  final String type; // 'applied', 'interview', 'offer', 'rejection', 'update'

  TimelineEvent({
    required this.date,
    required this.title,
    this.description,
    required this.type,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      date: (map['date'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      description: map['description'],
      type: map['type'] ?? 'update',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'title': title,
      'description': description,
      'type': type,
    };
  }
}