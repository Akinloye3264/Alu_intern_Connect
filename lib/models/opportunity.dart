import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Opportunity extends Equatable {
  final String opportunityId;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final List<String> skillsRequired;
  final String commitment;
  final String locationType;
  final bool isOpen;
  final DateTime createdAt;

  const Opportunity({
    required this.opportunityId,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    this.skillsRequired = const [],
    required this.commitment,
    required this.locationType,
    this.isOpen = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'opportunityId': opportunityId,
    'startupId': startupId,
    'startupName': startupName,
    'title': title,
    'description': description,
    'category': category,
    'skillsRequired': skillsRequired,
    'commitment': commitment,
    'locationType': locationType,
    'isOpen': isOpen,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Opportunity.fromMap(Map<String, dynamic> map) => Opportunity(
    opportunityId: map['opportunityId'] ?? '',
    startupId: map['startupId'] ?? '',
    startupName: map['startupName'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? 'Other',
    skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
    commitment: map['commitment'] ?? '',
    locationType: map['locationType'] ?? '',
    isOpen: map['isOpen'] ?? true,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [
    opportunityId,
    startupId,
    title,
    category,
    skillsRequired,
    isOpen,
  ];
}
