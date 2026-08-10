import 'package:equatable/equatable.dart';
import '../../domain/models/series_model.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();
  
  @override
  List<Object> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumLoaded extends PremiumState {
  final List<SeriesModel> series;

  const PremiumLoaded(this.series);

  @override
  List<Object> get props => [series];
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);

  @override
  List<Object> get props => [message];
}
