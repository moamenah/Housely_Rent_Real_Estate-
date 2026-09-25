import 'package:equatable/equatable.dart';

import '../../../core/constants/app_assets.dart';

/// Model layer of the onboarding feature: the page content itself.
///
/// Copy lives here (not in the View) so a designer can re-order, add or drop a
/// page by editing one list — the View and the ViewModel are page-count
/// agnostic.
class OnboardingPage extends Equatable {
  const OnboardingPage({
    required this.imageAsset,
    required this.titleLead,
    required this.titleAccent,
    required this.titleTail,
    required this.subtitle,
  });

  /// Blob illustration (already composed with its tinted back-shape).
  final String imageAsset;

  /// Headline is rendered in three spans so the accent words can be tinted
  /// `primary` without parsing strings at runtime.
  final String titleLead;
  final String titleAccent;
  final String titleTail;

  final String subtitle;

  /// Full headline as one plain string — handy for semantics and tests.
  String get title => '$titleLead$titleAccent$titleTail';

  static const List<OnboardingPage> pages = [
    OnboardingPage(
      imageAsset: AppAssets.onBoarding1,
      titleLead: 'Find the ',
      titleAccent: 'perfect place',
      titleTail: ' for your future house',
      subtitle:
          'Find the best place for your dream house with your family and '
          'loved ones.',
    ),
    OnboardingPage(
      imageAsset: AppAssets.onBoarding2,
      titleLead: 'Connect ',
      titleAccent: 'directly with owners',
      titleTail: ', no brokers in between',
      subtitle:
          'Message landlords and sellers yourself, compare offers and skip '
          'every hidden fee.',
    ),
    OnboardingPage(
      imageAsset: AppAssets.onBoarding3,
      titleLead: 'Book ',
      titleAccent: 'your visit',
      titleTail: ' in a single tap',
      subtitle:
          'Schedule viewings, save your favorites and move into your new '
          'home with confidence.',
    ),
  ];

  @override
  List<Object?> get props =>
      [imageAsset, titleLead, titleAccent, titleTail, subtitle];
}
