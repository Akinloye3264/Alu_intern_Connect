import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/startup.dart';

class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Startup>> watchStartups() {
    return _db.collection(FirestorePaths.startups).snapshots().map((snapshot) {
      final startups = snapshot.docs
          .map((doc) => Startup.fromMap(doc.data()))
          .toList();
      startups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return startups;
    });
  }

  Future<void> setVerificationStatus(
    String startupId,
    StartupVerificationStatus status,
  ) {
    return _db.collection(FirestorePaths.startups).doc(startupId).update({
      'verificationStatus': status.name,
      'verificationReviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
