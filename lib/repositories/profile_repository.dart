import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';

class ProfileRepository {
  final FirebaseFirestore _db;

  ProfileRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<void> updateStudentProfile({
    required String uid,
    required List<String> skills,
    required String bio,
  }) {
    return _db.collection(FirestorePaths.users).doc(uid).update({
      'skills': skills,
      'bio': bio.trim(),
    });
  }
}
