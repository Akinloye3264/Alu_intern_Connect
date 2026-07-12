import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app_user.dart';
import '../../../models/startup.dart';
import '../../../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _authSub;
  int _authEpoch = 0;

  AuthCubit(this._repo) : super(AuthInitial()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSub = _repo.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _authEpoch++;
        emit(Unauthenticated());
      } else {
        final epoch = ++_authEpoch;
        try {
          await _resolveSignedInUser(firebaseUser, epoch);
        } catch (_) {
          if (_repo.currentUser == null) {
            emit(Unauthenticated());
            return;
          }
          emit(
            const AuthError(
              'Signed in, but your profile could not be loaded. Please try again.',
            ),
          );
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
      emit(Authenticated(appUser));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } on ArgumentError catch (e) {
      emit(AuthError(e.message?.toString() ?? 'Invalid account details.'));
    } catch (e) {
      emit(const AuthError('Sign-up incomplete. Please try again.'));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final epoch = ++_authEpoch;
    emit(AuthLoginLoading());
    try {
      await _repo.signIn(email: email, password: password);
      final user = _repo.currentUser;
      if (user == null) {
        emit(const AuthError('Sign-in did not complete. Please try again.'));
        return;
      }
      await _resolveSignedInUser(user, epoch);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (e) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoginLoading());
    try {
      final result = await _repo.signInWithGoogle();
      if (result.user.uid.isEmpty) {
        emit(Unauthenticated());
        return;
      }
      final existingProfile = await _repo.fetchUserProfile(result.user.uid);
      if (existingProfile == null) {
        final role =
            result.user.email.trim().toLowerCase().endsWith('@alustudent.com')
            ? UserRole.student
            : UserRole.startup;
        await _repo.completeGoogleSignUp(result.user, role);
      }
      final firebaseUser = _repo.currentUser;
      if (firebaseUser == null) {
        emit(Unauthenticated());
      } else {
        await _resolveSignedInUser(firebaseUser, _authEpoch);
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } on ArgumentError catch (e) {
      await _repo.signOut();
      emit(
        AuthError(e.message?.toString() ?? 'Google sign-in is not allowed.'),
      );
    } catch (e) {
      emit(AuthError('Google sign-in failed: $e'));
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

  Future<void> signOut() async {
    _authEpoch++;
    emit(Unauthenticated());
    try {
      await _repo.signOut();
    } catch (_) {
      if (_repo.currentUser != null) {
        emit(const AuthError('Could not sign out. Please try again.'));
      }
    }
  }

  Future<void> checkVerificationStatus() async {
    final user = _repo.currentUser;
    if (user == null) {
      emit(Unauthenticated());
      return;
    }
    emit(AuthLoading());
    try {
      await _resolveSignedInUser(user, _authEpoch);
    } catch (_) {
      emit(const AuthError('Could not refresh the approval status.'));
    }
  }

  Future<void> refreshProfile() async {
    final user = _repo.currentUser;
    if (user != null) await _resolveSignedInUser(user, _authEpoch);
  }

  Future<void> _resolveSignedInUser(User firebaseUser, int epoch) async {
    await firebaseUser.reload();
    final refreshed = _repo.currentUser;
    if (!_isCurrentAuthRequest(firebaseUser, epoch) || refreshed == null) return;
    final profile = await _repo.fetchUserProfile(refreshed.uid);
    if (!_isCurrentAuthRequest(firebaseUser, epoch)) return;
    if (profile == null) {
      emit(
        const AuthError(
          'Your account is signed in, but its app profile is missing.',
        ),
      );
      return;
    }
    if (profile.role == UserRole.startup) {
      final status = await _repo.getStartupVerificationStatus(profile.uid);
      if (!_isCurrentAuthRequest(firebaseUser, epoch)) return;
      if (status != StartupVerificationStatus.approved) {
        emit(StartupVerificationPending(profile, status));
        return;
      }
    }
    if (!_isCurrentAuthRequest(firebaseUser, epoch)) return;
    emit(Authenticated(profile));
  }

  bool _isCurrentAuthRequest(User user, int epoch) {
    return epoch == _authEpoch && _repo.currentUser?.uid == user.uid;
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
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Wait a moment or reset your password.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
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
