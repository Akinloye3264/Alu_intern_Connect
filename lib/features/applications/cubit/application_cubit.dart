import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/application.dart';
import '../../../repositories/application_repository.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repo;
  StreamSubscription? _sub;

  ApplicationCubit(this._repo) : super(ApplicationIdle());

  void loadForStudent(String studentUid) {
    emit(ApplicationLoading());
    _sub?.cancel();
    _sub = _repo
        .watchStudentApplications(studentUid)
        .listen(
          (apps) => emit(ApplicationLoaded(apps)),
          onError: (e) => emit(ApplicationError(e.toString())),
        );
  }

  void loadForOpportunity(String opportunityId) {
    emit(ApplicationLoading());
    _sub?.cancel();
    _sub = _repo
        .watchApplicantsForOpportunity(opportunityId)
        .listen(
          (apps) => emit(ApplicationLoaded(apps)),
          onError: (e) => emit(ApplicationError(e.toString())),
        );
  }

  Future<void> checkApplied(String studentUid, String opportunityId) async {
    try {
      final already = await _repo.hasApplied(studentUid, opportunityId);
      if (already) emit(ApplicationSuccess());
    } catch (_) {}
  }

  Future<void> apply(Application application) async {
    emit(ApplicationLoading());
    try {
      final already = await _repo.hasApplied(
        application.studentUid,
        application.opportunityId,
      );
      if (already) {
        emit(ApplicationSuccess());
        return;
      }
      await _repo.apply(application);
      emit(ApplicationSuccess());
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> advanceStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    try {
      await _repo.updateStatus(applicationId, status);
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
