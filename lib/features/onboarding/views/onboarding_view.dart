import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../models/onboarding_page.dart';
import '../viewmodels/onboarding_cubit.dart';
import '../viewmodels/onboarding_state.dart';

/// Intro carousel shown after the splash screen (splash → onboarding → shell).
///
/// The View renders [OnboardingPage] models and forwards user gestures to
/// [OnboardingCubit]; it navigates exactly once, when the ViewModel flips to
/// `completed` (via *Next* on the last page, *Skip*, or *Get started*).
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  final PageController _pageController = PageController();

  /// Mirrors the page the user has actually swiped to, so we only animate the
  /// controller when the *button* changed the index (avoids animating to the
  /// page the user is already on).
  int _swipedIndex = 0;

  bool _navigated = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.index != previous.index,
      listener: (context, state) {
        if (state.isCompleted) {
          if (_navigated) return;
          _navigated = true;
          context.go(RoutePaths.login);
          return;
        }
        if (state.index != _swipedIndex) {
          _swipedIndex = state.index;
          _pageController.animateToPage(
            state.index,
            duration: AppDimensions.animationNormal,
            curve: Curves.easeOutCubic,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePadding,
                    AppDimensions.space8,
                    AppDimensions.pagePadding,
                    AppDimensions.space4,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _SkipButton(onPressed: cubit.skip),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingPage.pages.length,
                    onPageChanged: (index) {
                      _swipedIndex = index;
                      cubit.goTo(index);
                    },
                    itemBuilder: (context, index) => _OnboardingPage(
                      page: OnboardingPage.pages[index],
                      titleStyle: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                ),
                _PageIndicator(
                  activeIndex: state.index,
                  count: state.pageCount,
                ),
                const SizedBox(height: AppDimensions.space32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePadding,
                    0,
                    AppDimensions.pagePadding,
                    AppDimensions.space24,
                  ),
                  child: ElevatedButton(
                    key: const Key('onboarding_primary_cta'),
                    onPressed: cubit.next,
                    child: Text(state.isLastPage ? 'Get started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One carousel page: illustration + headline (accent tinted) + subtitle.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.titleStyle});

  final OnboardingPage page;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('onboarding-page-${page.imageAsset}'),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      child: Column(
        children: [
          // `contain` inside an Expanded box: scales to whatever height is
          // left over and letterboxes, so short screens never overflow.
          Expanded(
            child: Image.asset(
              page.imageAsset,
              fit: BoxFit.contain,
              semanticLabel: page.title,
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: page.titleLead),
                TextSpan(
                  text: page.titleAccent,
                  style: TextStyle(color: AppColors.primary),
                ),
                TextSpan(text: page.titleTail),
              ],
            ),
            key: const Key('onboarding_headline'),
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: _subtitleStyle,
          ),
          const SizedBox(height: AppDimensions.space16),
        ],
      ),
    );
  }

  static const TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
  );
}

/// Pill + dots pager. The active dot grows into a pill (24×12) while the
/// others shrink back to 12×12 circles — matches the design's indicator.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.space8),
          AnimatedContainer(
            key: ValueKey('onboarding-dot-$i'),
            duration: AppDimensions.animationFast,
            curve: Curves.easeOut,
            width: i == activeIndex ? 24 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: i == activeIndex ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
        ],
      ],
    );
  }
}

/// Top-right dismiss action — neutral outline, so it never competes with the
/// primary CTA at the bottom.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
      child: const Text('Skip'),
    );
  }
}
