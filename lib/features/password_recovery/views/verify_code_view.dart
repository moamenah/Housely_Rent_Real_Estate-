import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../auth/views/widgets/auth_cta_button.dart';
import '../viewmodels/password_recovery_cubit.dart';
import '../viewmodels/password_recovery_state.dart';
import 'widgets/otp_input.dart';
import 'widgets/recovery_header.dart';

/// Step 2 — enter the code sent to the chosen contact.
///
/// The box block sits in the space the header leaves free, so opening the
/// keyboard (which shrinks the body) pulls it up toward the subtitle, the way
/// the design's keyboard state does.
class VerifyCodeView extends StatelessWidget {
  const VerifyCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryCubit, PasswordRecoveryState>(
      listenWhen: (previous, current) =>
          previous.verifyStatus != current.verifyStatus,
      listener: (context, state) {
        if (state.isVerified) {
          FocusManager.instance.primaryFocus?.unfocus();
          context.go(RoutePaths.resetPassword);
          return;
        }
        if (state.isVerifyingFailed) {
          context.showSnack(
            state.failure?.message ?? 'We could not verify the code.',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PasswordRecoveryCubit>();

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
                  const RecoveryHeader(
                    title: 'Verify your Email',
                    // Broken a word earlier than the mockup: the design's
                    // compact font fits '…that have been sent' on one line,
                    // the app font does not, and an early break keeps the
                    // caption at two lines instead of orphaning 'sent'.
                    subtitle:
                        'Please enter ${PasswordRecoveryState.codeLength} '
                        'digit verification that\n'
                        'have been sent to your email address',
                    backLocation: RoutePaths.forgotPassword,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // The design parks the boxes ~40% down the screen and
                        // leaves the larger share of the free space below the
                        // resend link — so opening the keyboard shrinks the
                        // gap and lifts the block, as in the design's
                        // keyboard state.
                        const Spacer(flex: 27),
                        OtpInput(
                          code: state.code,
                          length: PasswordRecoveryState.codeLength,
                          onChanged: cubit.codeChanged,
                        ),
                        if (state.codeError != null) ...[
                          const SizedBox(height: AppDimensions.space8),
                          Text(
                            state.codeError!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space24),
                        ] else
                          const SizedBox(height: AppDimensions.space40),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Didn't receive code ?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray900,
                                ),
                              ),
                              SizedBox(height: AppDimensions.space4),
                              _ResendCodeButton(),
                            ],
                          ),
                        ),
                        const Spacer(flex: 73),
                      ],
                    ),
                  ),
                  AuthCtaButton(
                    label: 'Verify',
                    isLoading: state.isVerifying,
                    onPressed: cubit.verifyCode,
                    buttonKey: const Key('verify_code_button'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 'Resend code' — red, exactly as drawn, until the backend ships a resend.
class _ResendCodeButton extends StatelessWidget {
  const _ResendCodeButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.showSnack(
        "Resend code isn't available in this build yet.",
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.error,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      child: const Text('Resend code'),
    );
  }
}
