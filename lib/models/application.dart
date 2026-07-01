import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ApplicationStatus { applied, underReview, interview, accepted, closed }

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.closed:
        return 'Closed';
    }
  }
}

class Application extends Equatable {
  final String applicationId;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String studentUid;
  final String studentName;
  final String resumeUrl;
  final List<String> studentSkills;
  final ApplicationStatus status;
  final String message;
  final DateTime appliedAt;

  const Application({
    required this.applicationId,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.studentUid,
    required this.studentName,
    this.resumeUrl = '',
    this.studentSkills = const [],
    this.status = ApplicationStatus.applied,
    this.message = '',
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() => {
    'applicationId': applicationId,
    'opportunityId': opportunityId,
    'opportunityTitle': opportunityTitle,
    'startupName': startupName,
    'studentUid': studentUid,
    'studentName': studentName,
    'resumeUrl': resumeUrl,
    'studentSkills': studentSkills,
    'status': status.name,
    'message': message,
    'appliedAt': Timestamp.fromDate(appliedAt),
  };

  factory Application.fromMap(Map<String, dynamic> map) => Application(
    applicationId: map['applicationId'] ?? '',
    opportunityId: map['opportunityId'] ?? '',
    opportunityTitle: map['opportunityTitle'] ?? '',
    startupName: map['startupName'] ?? '',
    studentUid: map['studentUid'] ?? '',
    studentName: map['studentName'] ?? '',
    resumeUrl: map['resumeUrl'] ?? '',
    studentSkills: List<String>.from(map['studentSkills'] ?? []),
    status: ApplicationStatus.values.firstWhere(
      (s) => s.name == map['status'],
      orElse: () => ApplicationStatus.applied,
    ),
    message: map['message'] ?? '',
    appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [applicationId, opportunityId, studentUid, status];
}
