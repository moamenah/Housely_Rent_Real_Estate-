import 'package:equatable/equatable.dart';

import '../models/onboarding_page.dart';

/// Lifecycle of the onboarding flow.
///
/// Deliberately not the app-wide `RequestStatus`: this screen never loads or
/// fetches anything, so pretending it has `loading/success` phases would only
/// add dead branches to the View. `completed` is the one-shot signal the View
/// listens for to navigate away.
enum OnboardingStatus { browsing, completed }

/// State of the onboarding ViewModel.
class OnboardingState extends Equatable {
  const OnboardingState({
    this.index = 0,
    this.status = OnboardingStatus.browsing,
  });

  /// Index of the page currently shown (0-based).
  final int index;

  final OnboardingStatus status;

  /// Derived from the model so a new page only has to be added to
  /// [OnboardingPage.pages].
  int get pageCount => OnboardingPage.pages.length;

  bool get isLastPage => index >= pageCount - 1;

  bool get isCompleted => status == OnboardingStatus.completed;

  OnboardingState copyWith({int? index, OnboardingStatus? status}) {
    return OnboardingState(
      index: index ?? this.index,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [index, status];
}
