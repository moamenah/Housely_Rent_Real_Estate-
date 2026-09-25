import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Caption rendered above every auth input ('Email', 'Username', 'Password').
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
    );
  }
}

/// Input text color shared by both auth forms (near-black, per the design).
const TextStyle authInputStyle = TextStyle(color: AppColors.dark);

/// Input decoration shared by the sign-in and sign-up forms.
///
/// The theme draws text fields borderless; the design needs a visible outline
/// that is gray at rest and purple on focus, with the field blending into the
/// page background. Error borders (red) and the hint color come from the
/// theme, so the error state needs no extra code here.
InputDecoration authInputDecoration({
  String? hintText,
  String? errorText,
  Widget? suffixIcon,
}) {
  const radius = BorderRadius.all(Radius.circular(AppDimensions.radiusLg));
  return InputDecoration(
    filled: true,
    fillColor: AppColors.background,
    hintText: hintText,
    errorText: errorText,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.space16,
      vertical: AppDimensions.space16,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColors.primary),
    ),
  );
}
