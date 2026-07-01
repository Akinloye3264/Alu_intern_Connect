import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app_user.dart';
import '../../../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _authSub;

  AuthCubit(this._repo) : super(AuthInitial()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSub = _repo.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        emit(Unauthenticated());
      } else {
        try {
          await _resolveSignedInUser(firebaseUser);
        } catch (_) {
          emit(Unauthenticated());
        }
      }
    });
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String startupWebsite = '',
    String registrationNumber = '',
  }) async {
    emit(AuthLoading());
    try {
      final appUser = await _repo.signUp(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        startupWebsite: startupWebsite,
        registrationNumber: registrationNumber,
      );
      emit(EmailVerificationRequired(appUser.email));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } on ArgumentError catch (e) {
      emit(AuthError(e.message?.toString() ?? 'Invalid account details.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repo.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (e) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final result = await _repo.signInWithGoogle();
      if (result.user.uid.isEmpty) {
        emit(Unauthenticated());
        return;
      }
      if (result.isNewUser) {
        emit(NeedsRoleSelection(result.user));
      } else {
        final firebaseUser = _repo.currentUser;
        if (firebaseUser == null) {
          emit(Unauthenticated());
        } else {
          await _resolveSignedInUser(firebaseUser);
        }
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (e) {
      emit(const AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> completeGoogleSignUp(AppUser partialUser, UserRole role) async {
    emit(AuthLoading());
    try {
      final user = await _repo.completeGoogleSignUp(partialUser, role);
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError('Failed to save profile. Please try again.'));
    }
  }

  Future<void> signOut() => _repo.signOut();

  Future<void> resendVerificationEmail() async {
    await _repo.resendVerificationEmail();
  }

  Future<void> checkVerificationStatus() async {
    emit(AuthLoading());
    try {
      await _repo.refreshAndCheckVerified();
      final user = _repo.currentUser;
      if (user == null) {
        emit(Unauthenticated());
      } else {
        await _resolveSignedInUser(user);
      }
    } catch (_) {
      emit(const AuthError('Could not check verification status.'));
    }
  }

  Future<void> refreshProfile() async {
    final user = _repo.currentUser;
    if (user != null) await _resolveSignedInUser(user);
  }

  Future<void> _resolveSignedInUser(User firebaseUser) async {
    await firebaseUser.reload();
    final refreshed = _repo.currentUser ?? firebaseUser;
    if (!refreshed.emailVerified) {
      emit(EmailVerificationRequired(refreshed.email ?? ''));
      return;
    }
    final profile = await _repo.fetchUserProfile(refreshed.uid);
    if (profile == null) {
      emit(Unauthenticated());
      return;
    }
    if (profile.role == UserRole.startup &&
        !await _repo.isStartupVerified(profile.uid)) {
      emit(StartupVerificationPending(profile));
      return;
    }
    emit(Authenticated(profile));
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
