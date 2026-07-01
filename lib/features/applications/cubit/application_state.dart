import 'package:equatable/equatable.dart';
import '../../../models/application.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();
  @override
  List<Object?> get props => [];
}

class ApplicationLoading extends ApplicationState {}

class ApplicationIdle extends ApplicationState {}

class ApplicationSuccess extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  final List<Application> applications;
  const ApplicationLoaded(this.applications);

  List<Application> byStatus(ApplicationStatus status) =>
      applications.where((a) => a.status == status).toList();

  @override
  List<Object?> get props => [applications];
}

class ApplicationError extends ApplicationState {
  final String message;
  const ApplicationError(this.message);
  @override
  List<Object?> get props => [message];
}
