import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/error_view.dart';
import '../viewmodels/splash_cubit.dart';
import '../viewmodels/splash_state.dart';

/// Branded splash screen.
///
/// The View owns **only** presentation: it plays the intro animation and
/// navigates when the ViewModel reports readiness. Bootstrap work (and the
/// minimum display time) live in [SplashCubit] so they are unit-testable.
class SplashView extends StatelessWidget {
  const SplashView({super.key, this.bootstrap});

  /// Cold-start work handed over to the ViewModel — provided by the router so
  /// the View never touches the service locator.
  final Future<void> Function()? bootstrap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(bootstrap: bootstrap)..start(),
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  /// Total intro length; the Cubit keeps the screen visible a little longer.
  static const Duration _animationDuration = Duration(milliseconds: 1600);

  // Staged timeline — no dispose() needed for plain Intervals.
  static const Interval _logoInterval = Interval(
    0,
    0.45,
    curve: Curves.easeOutCubic,
  );
  static const Interval _shadowInterval = Interval(
    0.32,
    0.62,
    curve: Curves.easeOut,
  );
  static const Interval _wordmarkInterval = Interval(
    0.55,
    1,
    curve: Curves.easeOutCubic,
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animationDuration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) => current.isReady && !previous.isReady,
      // `go()` swaps the location, so splash is gone from the stack — pressing
      // back on onboarding exits the app instead of replaying the intro.
      listener: (context, state) => context.go(RoutePaths.onboarding),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: BlocBuilder<SplashCubit, SplashState>(
              builder: (context, state) {
                if (state.hasError) {
                  return ErrorView(
                    message: state.failure?.message ?? 'Please try again.',
                    onRetry: context.read<SplashCubit>().retry,
                  );
                }
                return _buildAnimatedLogo();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final logoT = _logoInterval.transform(_controller.value);
        final shadowT = _shadowInterval.transform(_controller.value);
        final wordmarkT = _wordmarkInterval.transform(_controller.value);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.86 + 0.14 * logoT,
              child: Opacity(
                opacity: logoT,
                child: SvgPicture.asset(
                  AppAssets.appLogo,
                  width: 116,
                  semanticsLabel: 'Housely logo',
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Opacity(
              opacity: shadowT,
              child: Transform.scale(
                scale: 0.8 + 0.2 * shadowT,
                child: Container(
                  width: 132,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary100.withValues(alpha: .8),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 52),
            Opacity(
              opacity: wordmarkT,
              child: Transform.translate(
                offset: Offset(0, 14 * (1 - wordmarkT)),
                child: Transform.translate(
                  // Trailing letter-spacing shifts the optical center left —
                  // nudge it back by half the spacing.
                  offset: const Offset(2.5, 0),
                  child: Text(
                    'HOUSELY',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
