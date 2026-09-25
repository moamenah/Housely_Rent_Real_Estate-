import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/features/onboarding/models/onboarding_page.dart';
import 'package:housely/features/onboarding/viewmodels/onboarding_cubit.dart';
import 'package:housely/features/onboarding/viewmodels/onboarding_state.dart';

void main() {
  final lastPage = OnboardingPage.pages.length - 1;

  group('OnboardingCubit', () {
    test('starts on the first page in browsing state', () {
      final cubit = OnboardingCubit();
      addTearDown(cubit.close);

      expect(cubit.state.index, 0);
      expect(cubit.state.isLastPage, isFalse);
      expect(cubit.state.isCompleted, isFalse);
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'next() walks through every page, then completes',
      build: OnboardingCubit.new,
      act: (cubit) async {
        for (var i = 0; i < lastPage; i++) {
          cubit.next();
        }
        cubit.next(); // on the last page → finishes
      },
      expect: () => [
        for (var i = 1; i <= lastPage; i++) OnboardingState(index: i),
        OnboardingState(
          index: lastPage,
          status: OnboardingStatus.completed,
        ),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'skip() completes from any page',
      build: OnboardingCubit.new,
      act: (cubit) {
        cubit.next();
        cubit.skip();
      },
      expect: () => [
        const OnboardingState(index: 1),
        const OnboardingState(index: 1, status: OnboardingStatus.completed),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goTo() ignores out-of-range and duplicate indices',
      build: OnboardingCubit.new,
      act: (cubit) {
        cubit.goTo(0); // same as current
        cubit.goTo(-1);
        cubit.goTo(OnboardingPage.pages.length + 5);
        cubit.goTo(2);
      },
      expect: () => const [OnboardingState(index: 2)],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits completion only once — no gestures leak after leaving',
      build: OnboardingCubit.new,
      act: (cubit) {
        cubit.skip();
        cubit.skip();
        cubit.next();
        cubit.goTo(2);
      },
      expect: () => const [OnboardingState(status: OnboardingStatus.completed)],
    );
  });
}
