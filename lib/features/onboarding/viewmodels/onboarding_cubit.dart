import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_state.dart';

/// ViewModel of the onboarding screen: a plain, synchronous state machine over
/// the page index plus a one-shot completion signal. The View owns the
/// `PageController` and the navigation; this class owns the decisions.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  /// Jump to a page (dot taps / swipe callbacks). Ignores out-of-range and
  /// no-op updates so a swipe can never fight the Next button.
  void goTo(int index) {
    if (state.isCompleted) return;
    if (index == state.index) return;
    if (index < 0 || index >= state.pageCount) return;
    emit(state.copyWith(index: index));
  }

  /// Advances to the next page, or finishes when the last one is reached.
  void next() {
    if (state.isLastPage) {
      complete();
    } else {
      goTo(state.index + 1);
    }
  }

  /// "Skip" — leaves the flow from any page.
  void skip() => complete();

  /// Emits exactly once; repeated taps cannot trigger a second navigation.
  void complete() {
    if (state.isCompleted) return;
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
