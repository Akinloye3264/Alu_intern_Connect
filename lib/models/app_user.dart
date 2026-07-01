import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { student, startup }

class AppUser extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final List<String> skills;
  final String bio;
  final String photoUrl;
  final String resumeUrl;
  final String resumeFileName;
  final String identityImageUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.skills = const [],
    this.bio = '',
    this.photoUrl = '',
    this.resumeUrl = '',
    this.resumeFileName = '',
    this.identityImageUrl = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'role': role.name,
    'skills': skills,
    'bio': bio,
    'photoUrl': photoUrl,
    'resumeUrl': resumeUrl,
    'resumeFileName': resumeFileName,
    'identityImageUrl': identityImageUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid'] ?? '',
    fullName: map['fullName'] ?? '',
    email: map['email'] ?? '',
    role: UserRole.values.firstWhere(
      (r) => r.name == map['role'],
      orElse: () => UserRole.student,
    ),
    skills: List<String>.from(map['skills'] ?? []),
    bio: map['bio'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
    resumeUrl: map['resumeUrl'] ?? '',
    resumeFileName: map['resumeFileName'] ?? '',
    identityImageUrl: map['identityImageUrl'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  AppUser copyWith({
    String? fullName,
    UserRole? role,
    List<String>? skills,
    String? bio,
    String? photoUrl,
    String? resumeUrl,
    String? resumeFileName,
    String? identityImageUrl,
  }) => AppUser(
    uid: uid,
    fullName: fullName ?? this.fullName,
    email: email,
    role: role ?? this.role,
    skills: skills ?? this.skills,
    bio: bio ?? this.bio,
    photoUrl: photoUrl ?? this.photoUrl,
    resumeUrl: resumeUrl ?? this.resumeUrl,
    resumeFileName: resumeFileName ?? this.resumeFileName,
    identityImageUrl: identityImageUrl ?? this.identityImageUrl,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    role,
    skills,
    bio,
    photoUrl,
    resumeUrl,
    resumeFileName,
    identityImageUrl,
  ];
}
