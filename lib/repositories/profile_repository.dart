import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/firestore_paths.dart';

class ProfileRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  ProfileRepository({FirebaseFirestore? db, FirebaseStorage? storage})
    : _db = db ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

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

  Future<String> uploadResume({
    required String uid,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('users/$uid/resume/${_safeName(fileName)}');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _resumeContentType(fileName)),
    );
    final url = await ref.getDownloadURL();
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'resumeUrl': url,
      'resumeFileName': fileName,
      'resumeUpdatedAt': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Future<String> uploadIdentityImage({
    required String uid,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('users/$uid/identity/${_safeName(fileName)}');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _imageContentType(fileName)),
    );
    final url = await ref.getDownloadURL();
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'identityImageUrl': url,
      'identityImageUpdatedAt': FieldValue.serverTimestamp(),
    });
    return url;
  }

  String _safeName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '${DateTime.now().millisecondsSinceEpoch}_$sanitized';
  }

  String _resumeContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'pdf') return 'application/pdf';
    if (extension == 'doc') return 'application/msword';
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }

  String _imageContentType(String fileName) {
    return fileName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }
}
