import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';

/// Home tab.
///
/// The design's bottom bar ships five tabs, and Home is the first of them —
/// but its screen has no mockup yet, so the tab renders an honest placeholder
/// rather than invented UI. Replace this file when the design lands.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      icon: Icons.home_outlined,
      title: 'Home',
      message: "Your home feed isn't part of this build yet — "
          'the full listing feed lives in the Explore tab.',
    );
  }
}
