import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/firestore_paths.dart';
import '../core/config/env.dart';
import '../models/app_user.dart';
import '../models/startup.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String startupWebsite = '',
    String registrationNumber = '',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (role == UserRole.student &&
        !normalizedEmail.endsWith('@alustudent.com')) {
      throw ArgumentError('Students must use an @alustudent.com email.');
    }
    if (role == UserRole.startup &&
        (startupWebsite.trim().isEmpty || registrationNumber.trim().isEmpty)) {
      throw ArgumentError(
        'Startup website and registration number are required.',
      );
    }
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') rethrow;
      // Deleting only the Firestore profile leaves the Firebase Auth account.
      // Re-authenticate that account and rebuild its profile when the password
      // supplied by its owner is valid.
      cred = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final existingProfile = await _db
          .collection(FirestorePaths.users)
          .doc(cred.user!.uid)
          .get();
      if (existingProfile.exists) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'That email is already registered. Please sign in instead.',
        );
      }
    }
    final uid = cred.user!.uid;

    final appUser = AppUser(
      uid: uid,
      fullName: fullName.trim(),
      email: normalizedEmail,
      role: role,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(_db.collection(FirestorePaths.users).doc(uid), appUser.toMap());
    if (role == UserRole.startup) {
      final startup = Startup(
        startupId: uid,
        ownerUid: uid,
        name: fullName.trim(),
        email: normalizedEmail,
        description: '',
        category: 'Other',
        website: startupWebsite.trim(),
        registrationNumber: registrationNumber.trim(),
        createdAt: DateTime.now(),
      );
      batch.set(
        _db.collection(FirestorePaths.startups).doc(uid),
        startup.toMap(),
      );
    }
    await batch.commit();
    return appUser;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<({AppUser user, bool isNewUser})> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(
      serverClientId: Env.googleServerClientId.isEmpty
          ? null
          : Env.googleServerClientId,
    ).signIn();
    if (googleUser == null) return (user: _emptyUser(), isNewUser: false);

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;
    final isNew = userCred.additionalUserInfo?.isNewUser ?? true;

    final partialUser = AppUser(
      uid: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      role: UserRole.student,
      photoUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
    );

    return (user: partialUser, isNewUser: isNew);
  }

  Future<AppUser> completeGoogleSignUp(AppUser user, UserRole role) async {
    if (role == UserRole.student &&
        !user.email.trim().toLowerCase().endsWith('@alustudent.com')) {
      throw ArgumentError('Students must use an @alustudent.com email.');
    }
    if (role == UserRole.startup) {
      throw ArgumentError(
        'Startups must use the full signup form for organization verification.',
      );
    }
    final finalUser = user.copyWith(role: role);
    await _db
        .collection(FirestorePaths.users)
        .doc(finalUser.uid)
        .set(finalUser.toMap());
    return finalUser;
  }

  AppUser _emptyUser() => AppUser(
    uid: '',
    fullName: '',
    email: '',
    role: UserRole.student,
    createdAt: DateTime.now(),
  );

  Future<void> signOut() async {
    final signedInWithGoogle = _auth.currentUser?.providerData.any(
      (provider) => provider.providerId == 'google.com',
    ) ?? false;
    await _auth.signOut();
    // A user may have signed in with email/password, and the Google plugin can
    // also be unavailable on some platforms. Neither case should prevent the
    // Firebase session from being closed.
    if (signedInWithGoogle) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Firebase Auth is the source of truth for the app session.
      }
    }
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final doc = await _db.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Future<StartupVerificationStatus> getStartupVerificationStatus(
    String uid,
  ) async {
    final doc = await _db.collection(FirestorePaths.startups).doc(uid).get();
    if (!doc.exists) return StartupVerificationStatus.pending;
    return StartupVerificationStatus.values.firstWhere(
      (s) => s.name == doc.data()?['verificationStatus'],
      orElse: () => StartupVerificationStatus.pending,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

}
