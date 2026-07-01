import 'package:equatable/equatable.dart';
import '../../../models/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class EmailVerificationRequired extends AuthState {
  final String email;
  const EmailVerificationRequired(this.email);
  @override
  List<Object?> get props => [email];
}

class StartupVerificationPending extends AuthState {
  final AppUser user;
  const StartupVerificationPending(this.user);
  @override
  List<Object?> get props => [user];
}

class NeedsRoleSelection extends AuthState {
  final AppUser partialUser;
  const NeedsRoleSelection(this.partialUser);
  @override
  List<Object?> get props => [partialUser];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
