import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/application.dart';

class ApplicationRepository {
  final FirebaseFirestore _db;
  ApplicationRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.applications);

  Future<void> apply(Application application) async {
    final docRef = _col.doc();
    final withId = Application(
      applicationId: docRef.id,
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      startupName: application.startupName,
      studentUid: application.studentUid,
      studentName: application.studentName,
      status: ApplicationStatus.applied,
      message: application.message,
      appliedAt: application.appliedAt,
    );
    await docRef.set(withId.toMap());
  }

  Stream<List<Application>> watchStudentApplications(String studentUid) {
    return _col
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Application.fromMap(d.data())).toList(),
        );
  }

  Stream<List<Application>> watchApplicantsForOpportunity(
    String opportunityId,
  ) {
    return _col
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Application.fromMap(d.data())).toList(),
        );
  }

  Future<void> updateStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    await _col.doc(applicationId).update({'status': status.name});
  }

  Future<bool> hasApplied(String studentUid, String opportunityId) async {
    final snap = await _col
        .where('studentUid', isEqualTo: studentUid)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
