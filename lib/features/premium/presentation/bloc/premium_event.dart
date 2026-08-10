import 'package:equatable/equatable.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object> get props => [];
}

class FetchSeriesData extends PremiumEvent {
  final String type;

  const FetchSeriesData({this.type = 'series'});

  @override
  List<Object> get props => [type];
}
