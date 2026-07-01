import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Startup extends Equatable {
  final String startupId;
  final String ownerUid;
  final String name;
  final String description;
  final String logoUrl;
  final bool isVerified;
  final String category;
  final String website;
  final String registrationNumber;
  final DateTime createdAt;

  const Startup({
    required this.startupId,
    required this.ownerUid,
    required this.name,
    required this.description,
    this.logoUrl = '',
    this.isVerified = false,
    required this.category,
    required this.website,
    required this.registrationNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'startupId': startupId,
    'ownerUid': ownerUid,
    'name': name,
    'description': description,
    'logoUrl': logoUrl,
    'isVerified': isVerified,
    'category': category,
    'website': website,
    'registrationNumber': registrationNumber,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Startup.fromMap(Map<String, dynamic> map) => Startup(
    startupId: map['startupId'] ?? '',
    ownerUid: map['ownerUid'] ?? '',
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    logoUrl: map['logoUrl'] ?? '',
    isVerified: map['isVerified'] ?? false,
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
    description,
    logoUrl,
    isVerified,
    category,
    website,
    registrationNumber,
  ];
}
