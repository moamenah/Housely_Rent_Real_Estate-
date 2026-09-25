import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../auth/views/widgets/auth_cta_button.dart';

/// Step 4 — confirmation. Terminal screen: no back arrow, 'Continue' starts a
/// fresh sign-in attempt with `go()`, which drops the whole recovery stack.
class PasswordChangedView extends StatelessWidget {
  const PasswordChangedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.space8,
            AppDimensions.pagePadding,
            AppDimensions.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: SvgPicture.asset(AppAssets.passwordSuccessIcon),
                ),
              ),
              const SizedBox(height: AppDimensions.space40),
              Text(
                'Success!',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Your password has been changed.\n'
                'Please log in again with a new password',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.gray400,
                ),
              ),
              const Spacer(flex: 2),
              AuthCtaButton(
                label: 'Continue',
                buttonKey: const Key('password_changed_continue_button'),
                onPressed: () => context.go(RoutePaths.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
