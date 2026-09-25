import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../auth/views/widgets/auth_field.dart';
import '../../auth/views/widgets/auth_cta_button.dart';
import '../viewmodels/password_recovery_cubit.dart';
import '../viewmodels/password_recovery_state.dart';
import 'widgets/recovery_header.dart';

/// Step 3 — pick the new password.
class CreatePasswordView extends StatelessWidget {
  const CreatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryCubit, PasswordRecoveryState>(
      listenWhen: (previous, current) =>
          previous.resetStatus != current.resetStatus,
      listener: (context, state) {
        if (state.isPasswordChanged) {
          FocusManager.instance.primaryFocus?.unfocus();
          context.go(RoutePaths.passwordChanged);
          return;
        }
        if (state.resetStatus == RequestStatus.failure) {
          // Policy/rejection failures are not the field's fault — they get a
          // banner, never a red border (same rule as the sign-in screen).
          context.showSnack(
            state.failure?.message ?? 'We could not change your password.',
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const RecoveryHeader(
                            title: 'Create New Password',
                            subtitle: 'Please enter a new password\nto change',
                            backLocation: RoutePaths.verifyCode,
                          ),
                          const SizedBox(height: AppDimensions.space40),
                          const AuthFieldLabel('New Password'),
                          const SizedBox(height: AppDimensions.space8),
                          TextField(
                            key: const Key('reset_new_password_field'),
                            style: authInputStyle,
                            obscureText: state.obscureNewPassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            autocorrect: false,
                            enableSuggestions: false,
                            onChanged: cubit.newPasswordChanged,
                            decoration: authInputDecoration(
                              hintText: 'Password',
                              errorText: state.newPasswordError,
                              suffixIcon: IconButton(
                                key: const Key('reset_obscure_toggle'),
                                onPressed: cubit.toggleObscureNewPassword,
                                tooltip: state.obscureNewPassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: SvgPicture.asset(
                                  state.obscureNewPassword
                                      ? AppAssets.hideIcon
                                      : AppAssets.showIcon,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space20),
                          const AuthFieldLabel('Confirm Password'),
                          const SizedBox(height: AppDimensions.space8),
                          TextField(
                            key: const Key('reset_confirm_password_field'),
                            style: authInputStyle,
                            obscureText: state.obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            autocorrect: false,
                            enableSuggestions: false,
                            onChanged: cubit.confirmPasswordChanged,
                            onSubmitted: (_) => cubit.changePassword(),
                            decoration: authInputDecoration(
                              hintText: 'Password',
                              errorText: state.confirmPasswordError,
                              suffixIcon: IconButton(
                                key: const Key('reset_confirm_obscure_toggle'),
                                onPressed: cubit.toggleObscureConfirmPassword,
                                tooltip: state.obscureConfirmPassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: SvgPicture.asset(
                                  state.obscureConfirmPassword
                                      ? AppAssets.hideIcon
                                      : AppAssets.showIcon,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AuthCtaButton(
                    label: 'Change password',
                    isLoading: state.isResetting,
                    onPressed: cubit.changePassword,
                    buttonKey: const Key('reset_change_password_button'),
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
