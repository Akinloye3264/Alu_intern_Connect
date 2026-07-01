import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  final FirebaseFirestore _db;
  OpportunityRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.opportunities);

  Future<void> post(Opportunity opp) async {
    final docRef = _col.doc();
    final withId = Opportunity(
      opportunityId: docRef.id,
      startupId: opp.startupId,
      startupName: opp.startupName,
      title: opp.title,
      description: opp.description,
      category: opp.category,
      skillsRequired: opp.skillsRequired,
      commitment: opp.commitment,
      locationType: opp.locationType,
      isOpen: true,
      createdAt: opp.createdAt,
    );
    await docRef.set(withId.toMap());
  }

  Stream<List<Opportunity>> watchOpenOpportunities() {
    return _col
        .where('isOpen', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Opportunity.fromMap(d.data())).toList(),
        );
  }

  Stream<List<Opportunity>> watchByStartup(String startupId) {
    return _col
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Opportunity.fromMap(d.data())).toList(),
        );
  }

  Future<void> update(Opportunity opp) async {
    await _col.doc(opp.opportunityId).update(opp.toMap());
  }

  Future<void> setOpen(String opportunityId, bool isOpen) async {
    await _col.doc(opportunityId).update({'isOpen': isOpen});
  }

  Future<void> delete(String opportunityId) async {
    await _col.doc(opportunityId).delete();
  }
}
