import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import 'splash_state.dart';

/// ViewModel of the splash screen.
///
/// Responsibilities are deliberately narrow: run the app bootstrap (DI warm-up,
/// cached reads, remote config, …) while guaranteeing the brand animation is
/// visible for at least [minimumDisplayDuration], then report readiness so the
/// View can navigate exactly once.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    Future<void> Function()? bootstrap,
    this.minimumDisplayDuration = const Duration(milliseconds: 1800),
  })  : _bootstrap = bootstrap,
        super(const SplashState());

  /// Cold-start work to await before entering the shell.
  final Future<void> Function()? _bootstrap;

  /// Keeps the logo on screen long enough to not feel like a flash.
  final Duration minimumDisplayDuration;

  bool _started = false;

  Future<void> start() async {
    // Guard against double-invocation (retry taps, rebuilds).
    if (_started && state.isLoading) return;
    _started = true;

    emit(state.copyWith(status: RequestStatus.loading, clearFailure: true));
    try {
      await Future.wait<void>([
        Future<void>.delayed(minimumDisplayDuration),
        _bootstrap?.call() ?? Future<void>.value(),
      ]);
      emit(state.copyWith(status: RequestStatus.success, clearFailure: true));
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          failure: FailureMapper.map(error),
        ),
      );
    }
  }

  /// Retry after a failed bootstrap.
  Future<void> retry() {
    _started = false;
    return start();
  }
}
