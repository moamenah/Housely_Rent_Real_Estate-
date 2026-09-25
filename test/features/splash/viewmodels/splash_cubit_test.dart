import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/core/enums/request_status.dart';
import 'package:housely/features/splash/viewmodels/splash_cubit.dart';
import 'package:housely/features/splash/viewmodels/splash_state.dart';

void main() {
  /// Zero delay keeps the suite instant; the delay itself is covered by the
  /// explicit timing test below.
  const noDelay = Duration.zero;

  group('SplashCubit', () {
    blocTest<SplashCubit, SplashState>(
      'emits [loading, success] once the bootstrap completes',
      build: () => SplashCubit(minimumDisplayDuration: noDelay),
      act: (cubit) => cubit.start(),
      expect: () => const [
        SplashState(status: RequestStatus.loading),
        SplashState(status: RequestStatus.success),
      ],
    );

    test('stays in loading until the minimum display duration elapsed',
        () async {
      final cubit = SplashCubit(
        minimumDisplayDuration: const Duration(milliseconds: 150),
      );
      addTearDown(cubit.close);

      cubit.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.isLoading, isTrue);

      await cubit.stream.firstWhere((state) => state.isReady);
    });

    test('maps a bootstrap error to a failure state', () async {
      final cubit = SplashCubit(
        minimumDisplayDuration: noDelay,
        bootstrap: () async => throw StateError('DI exploded'),
      );
      addTearDown(cubit.close);

      await cubit.start();

      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.failure, isNotNull);
      expect(cubit.state.failure!.message, contains('DI exploded'));
    });

    test('retry re-runs the bootstrap after a failure', () async {
      var shouldFail = true;
      final cubit = SplashCubit(
        minimumDisplayDuration: noDelay,
        bootstrap: () async {
          if (shouldFail) throw StateError('boom');
        },
      );
      addTearDown(cubit.close);

      await cubit.start();
      expect(cubit.state.hasError, isTrue);

      shouldFail = false;
      await cubit.retry();
      expect(cubit.state.isReady, isTrue);
    });

    test('does not start a second time while the first run is in flight',
        () async {
      var bootstrapCalls = 0;
      final gate = Completer<void>();
      final cubit = SplashCubit(
        minimumDisplayDuration: noDelay,
        bootstrap: () {
          bootstrapCalls += 1;
          return gate.future;
        },
      );
      addTearDown(cubit.close);

      cubit.start();
      cubit.start();
      await Future<void>.delayed(Duration.zero);

      expect(bootstrapCalls, 1);
      expect(cubit.state.isLoading, isTrue);

      gate.complete();
      await cubit.stream.firstWhere((state) => state.isReady);
    });
  });
}
