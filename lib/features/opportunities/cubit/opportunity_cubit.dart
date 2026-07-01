import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/skill_matcher.dart';
import '../../../models/opportunity.dart';
import '../../../repositories/opportunity_repository.dart';
import 'opportunity_state.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository _repo;
  StreamSubscription? _sub;

  OpportunityCubit(this._repo) : super(OpportunityLoading());

  void loadForStudent(List<String> studentSkills) {
    emit(OpportunityLoading());
    _sub?.cancel();
    _sub = _repo.watchOpenOpportunities().listen((list) {
      final recommended = SkillMatcher.recommend(studentSkills, list);
      emit(OpportunityLoaded(all: list, recommended: recommended));
    }, onError: (e) => emit(OpportunityError(e.toString())));
  }

  void loadForStartup(String startupId) {
    emit(OpportunityLoading());
    _sub?.cancel();
    _sub = _repo
        .watchByStartup(startupId)
        .listen(
          (list) => emit(OpportunityLoaded(all: list)),
          onError: (e) => emit(OpportunityError(e.toString())),
        );
  }

  Future<void> post(Opportunity opp) async {
    try {
      await _repo.post(opp);
    } catch (e) {
      emit(OpportunityError(e.toString()));
      rethrow;
    }
  }

  Future<void> setOpen(String opportunityId, bool isOpen) =>
      _repo.setOpen(opportunityId, isOpen);

  Future<void> delete(String opportunityId) => _repo.delete(opportunityId);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
