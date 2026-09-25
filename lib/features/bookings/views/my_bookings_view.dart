import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';

/// My Booking tab.
///
/// The design's bottom bar ships five tabs; bookings have no screen yet, so
/// the tab renders an honest placeholder instead of invented UI. Replace
/// this file when the design lands.
class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      icon: Icons.event_note_outlined,
      title: 'My Booking',
      message: "Bookings aren't part of this build yet — "
          'your visits will be listed here once booking ships.',
    );
  }
}
