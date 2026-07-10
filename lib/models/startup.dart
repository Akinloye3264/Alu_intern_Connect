import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Admin-controlled review status. In the Firebase console this is stored
/// as a plain string on the startup's document (`startups/{uid}`) — flip it
/// from "pending" to "approved" to unlock posting for that startup, or set
/// it to "rejected" to deny the application.
enum StartupVerificationStatus { pending, approved, rejected }

class Startup extends Equatable {
  final String startupId;
  final String ownerUid;
  final String name;
  final String email;
  final String description;
  final String logoUrl;
  final StartupVerificationStatus verificationStatus;
  final String category;
  final String website;
  final String registrationNumber;
  final DateTime createdAt;

  const Startup({
    required this.startupId,
    required this.ownerUid,
    required this.name,
    this.email = '',
    required this.description,
    this.logoUrl = '',
    this.verificationStatus = StartupVerificationStatus.pending,
    required this.category,
    required this.website,
    required this.registrationNumber,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == StartupVerificationStatus.approved;

  Map<String, dynamic> toMap() => {
    'startupId': startupId,
    'ownerUid': ownerUid,
    'name': name,
    'email': email,
    'description': description,
    'logoUrl': logoUrl,
    'verificationStatus': verificationStatus.name,
    'category': category,
    'website': website,
    'registrationNumber': registrationNumber,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Startup.fromMap(Map<String, dynamic> map) => Startup(
    startupId: map['startupId'] ?? '',
    ownerUid: map['ownerUid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    description: map['description'] ?? '',
    logoUrl: map['logoUrl'] ?? '',
    verificationStatus: StartupVerificationStatus.values.firstWhere(
      (s) => s.name == map['verificationStatus'],
      orElse: () => StartupVerificationStatus.pending,
    ),
    category: map['category'] ?? 'Other',
    website: map['website'] ?? '',
    registrationNumber: map['registrationNumber'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [
    startupId,
    ownerUid,
    name,
    email,
    description,
    logoUrl,
    verificationStatus,
    category,
    website,
    registrationNumber,
  ];
}
