import 'package:equatable/equatable.dart';
import '../../../models/opportunity.dart';

abstract class OpportunityState extends Equatable {
  const OpportunityState();
  @override
  List<Object?> get props => [];
}

class OpportunityLoading extends OpportunityState {}

class OpportunityLoaded extends OpportunityState {
  final List<Opportunity> all;
  final List<Opportunity> recommended;

  const OpportunityLoaded({required this.all, this.recommended = const []});

  @override
  List<Object?> get props => [all, recommended];
}

class OpportunityError extends OpportunityState {
  final String message;
  const OpportunityError(this.message);
  @override
  List<Object?> get props => [message];
}
