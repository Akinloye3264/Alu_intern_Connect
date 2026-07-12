import 'package:equatable/equatable.dart';
import '../../../models/app_user.dart';
import '../../../models/startup.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class StartupVerificationPending extends AuthState {
  final AppUser user;
  final StartupVerificationStatus status;
  const StartupVerificationPending(this.user, this.status);
  @override
  List<Object?> get props => [user, status];
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
