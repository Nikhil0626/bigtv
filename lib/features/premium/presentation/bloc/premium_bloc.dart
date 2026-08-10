import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/premium_repo.dart';
import '../../domain/models/series_model.dart';
import 'premium_event.dart';
import 'premium_state.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final PremiumRepo _premiumRepo;

  PremiumBloc({required PremiumRepo premiumRepo})
      : _premiumRepo = premiumRepo,
        super(PremiumInitial()) {
    on<FetchSeriesData>(_onFetchSeriesData);
  }

  Future<void> _onFetchSeriesData(
    FetchSeriesData event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      final response = await _premiumRepo.getSeriesContent(type: event.type);
      if (response.statusCode == 200 && response.data != null) {
        List<SeriesModel> series = [];
        if (response.data is List) {
          series = (response.data as List)
              .map((e) => SeriesModel.fromJson(e))
              .toList();
        }
        emit(PremiumLoaded(series));
      } else {
        emit(const PremiumError('Failed to load premium series data'));
      }
    } catch (e) {
      emit(PremiumError('An error occurred: $e'));
    }
  }
}
