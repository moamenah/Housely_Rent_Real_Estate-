import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';

/// Readable shortcuts over `Theme.of(context)`.
extension ThemeContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a floating [SnackBar] without repeating boilerplate.
  void showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error600 : null,
        ),
      );
  }
}

/// Navigation helpers over `go_router`'s context extensions.
extension RouterContextX on BuildContext {
  /// Steps back to a pushed page, or jumps to [location] when this screen was
  /// reached with `go()` — there is nothing to pop in that case, and without
  /// the fallback the system back button would leave the app entirely.
  void goBackTo(String location) {
    canPop() ? pop() : go(location);
  }
}
