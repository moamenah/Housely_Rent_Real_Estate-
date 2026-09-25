import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../repositories/auth_repository.dart';
import '../viewmodels/sign_up_cubit.dart';
import '../viewmodels/sign_up_state.dart';
import 'widgets/auth_field.dart';
import 'widgets/social_button.dart';

/// Registration screen.
///
/// Same skeleton as [LoginView] — back arrow, header, stacked fields, primary
/// action, social row, sign-in link — plus the two extras from the design:
/// the username field and the "Agree with terms and privacy" gate.
class SignUpView extends StatelessWidget {
  const SignUpView({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(authRepository: authRepository),
      child: const _SignUpBody(),
    );
  }
}

class _SignUpBody extends StatefulWidget {
  const _SignUpBody();

  @override
  State<_SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<_SignUpBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    // Reachable from the sign-in screen, so it must work both as a pushed
    // page and as a plain location change.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }

  void _showStub(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("$feature isn't available in this build yet.")),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return BlocConsumer<SignUpCubit, SignUpState>(
      listenWhen: (previous, current) => current.status != previous.status,
      listener: (context, state) {
        if (state.isRegistered) {
          FocusManager.instance.primaryFocus?.unfocus();
          // Every session starts with the greeting/location step before the
          // shell is revealed.
          context.go(RoutePaths.locationPermission);
          return;
        }
        if (state.hasFailed) {
          // There is no credential to reject on sign-up, so every repository
          // failure escalates to a banner; validation stays inline.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.failure?.message ??
                      'We could not create your account.',
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SignUpCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.space8,
                AppDimensions.pagePadding,
                AppDimensions.space24,
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      key: const Key('signup_back_button'),
                      onPressed: () => _goBack(context),
                      icon: const Icon(Icons.arrow_back_outlined),
                      color: AppColors.gray900,
                      iconSize: 26,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),
                    Text(
                      'Register Account',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Sign in with your email and password\n'
                      'or social media to continue',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space32),

                    // --- Email -------------------------------------------------
                    const AuthFieldLabel('Email'),
                    const SizedBox(height: AppDimensions.space8),
                    TextField(
                      key: const Key('signup_email_field'),
                      controller: _emailController,
                      style: authInputStyle,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: cubit.emailChanged,
                      decoration: authInputDecoration(
                        hintText: 'Email',
                        errorText: state.emailError,
                      ),
                    ),

                    // --- Username ----------------------------------------------
                    const SizedBox(height: AppDimensions.space20),
                    const AuthFieldLabel('Username'),
                    const SizedBox(height: AppDimensions.space8),
                    TextField(
                      key: const Key('signup_username_field'),
                      controller: _usernameController,
                      style: authInputStyle,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: cubit.usernameChanged,
                      decoration: authInputDecoration(
                        hintText: 'Username',
                        errorText: state.usernameError,
                      ),
                    ),

                    // --- Password ----------------------------------------------
                    const SizedBox(height: AppDimensions.space20),
                    const AuthFieldLabel('Password'),
                    const SizedBox(height: AppDimensions.space8),
                    TextField(
                      key: const Key('signup_password_field'),
                      controller: _passwordController,
                      style: authInputStyle,
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: cubit.passwordChanged,
                      onSubmitted: (_) => cubit.submit(),
                      decoration: authInputDecoration(
                        hintText: 'Password',
                        errorText: state.passwordError,
                        suffixIcon: IconButton(
                          key: const Key('signup_obscure_toggle'),
                          onPressed: cubit.toggleObscurePassword,
                          tooltip: state.obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: SvgPicture.asset(
                            state.obscurePassword
                                ? AppAssets.hideIcon
                                : AppAssets.showIcon,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),

                    // --- Terms gate --------------------------------------------
                    const SizedBox(height: AppDimensions.space16),
                    GestureDetector(
                      onTap: cubit.toggleAgreeToTerms,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            key: const Key('signup_terms_checkbox'),
                            value: state.agreeToTerms,
                            onChanged: (_) => cubit.toggleAgreeToTerms(),
                          ),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray900,
                                ),
                                children: const [
                                  TextSpan(text: 'Agree with '),
                                  TextSpan(
                                    text: 'terms',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'privacy',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.termsError != null) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        state.termsError!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    // --- Primary action ----------------------------------------
                    const SizedBox(height: AppDimensions.space24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('signup_sign_up_button'),
                        onPressed: cubit.submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),
                    const Center(
                      child: Text(
                        'Or',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SocialButton(
                            label: 'Facebook',
                            asset: AppAssets.facebookIcon,
                            onTap: () =>
                                _showStub(context, 'Facebook sign-up'),
                          ),
                          const SizedBox(width: AppDimensions.space16),
                          SocialButton(
                            label: 'Google',
                            asset: AppAssets.googleIcon,
                            onTap: () => _showStub(context, 'Google sign-up'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),
                    Center(
                      // Wrap (not Row) so the pair stacks instead of
                      // overflowing on wide fonts or big text scales.
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account ?',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.gray900,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(RoutePaths.login),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.primary,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
