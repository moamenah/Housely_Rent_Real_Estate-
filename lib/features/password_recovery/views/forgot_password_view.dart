import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/views/widgets/auth_cta_button.dart';
import '../viewmodels/password_recovery_cubit.dart';
import '../viewmodels/password_recovery_state.dart';
import 'widgets/contact_option_card.dart';
import 'widgets/recovery_header.dart';

/// Step 1 — choose which masked contact receives the reset code.
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordRecoveryCubit, PasswordRecoveryState>(
      listenWhen: (previous, current) =>
          previous.contactsStatus != current.contactsStatus,
      listener: (context, state) {
        // The cards never turn red: losing the contact list is a transport
        // problem, so it is announced with a snackbar (and offers a retry
        // inline), exactly like the sign-in screen treats such failures.
        if (state.contactsStatus == RequestStatus.failure) {
          context.showSnack(
            state.failure?.message ?? 'We could not load your contacts.',
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
                            title: 'Forgot Password',
                            subtitle:
                                'Select which contact details should we use\n'
                                'to reset your password',
                            backLocation: RoutePaths.login,
                          ),
                          const SizedBox(height: AppDimensions.space32),
                          if (state.contactsStatus == RequestStatus.failure)
                            ErrorView(
                              message: state.failure?.message ??
                                  'We could not load your contacts.',
                              onRetry: cubit.loadContacts,
                            )
                          else if (state.contactsStatus !=
                              RequestStatus.success)
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: AppDimensions.space40),
                              child: AppLoadingIndicator(),
                            )
                          else
                            for (final contact in state.contacts) ...[
                              ContactOptionCard(
                                contact: contact,
                                iconAsset: contact.id == 'email'
                                    ? AppAssets.mailIcon
                                    : AppAssets.phoneIcon,
                                selected:
                                    contact.id == state.selectedContactId,
                                onTap: () => cubit.selectContact(contact.id),
                              ),
                              if (contact != state.contacts.last)
                                const SizedBox(
                                  height: AppDimensions.space20,
                                ),
                            ],
                        ],
                      ),
                    ),
                  ),
                  AuthCtaButton(
                    label: 'Continue',
                    buttonKey: const Key('forgot_password_continue_button'),
                    onPressed: state.selectedContactId == null
                        ? null
                        : () => context.go(RoutePaths.verifyCode),
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
