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
import '../viewmodels/login_cubit.dart';
import '../viewmodels/login_state.dart';
import 'widgets/auth_field.dart';
import 'widgets/social_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.authRepository});

  /// Injected by the router so the View never touches the service locator.
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(authRepository: authRepository),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    // Reachable both as a pushed page and as a plain location change.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.onboarding);
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

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) => current.status != previous.status,
      listener: (context, state) {
        if (state.isAuthenticated) {
          FocusManager.instance.primaryFocus?.unfocus();
          // Every session starts with the greeting/location step before the
          // shell is revealed.
          context.go(RoutePaths.locationPermission);
          return;
        }
        if (state.hasFailed && state.passwordError == null) {
          // Field-scoped errors are drawn in place; only transport/service
          // problems escalate to a snackbar.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.failure?.message ?? 'We could not sign you in.',
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();

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
                      'Welcome Back !',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Sign in with your email and password\nor social media to continue',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space32),
                    const AuthFieldLabel('Email'),
                    const SizedBox(height: AppDimensions.space8),







                    TextField(
                      key: const Key('login_email_field'),
                      controller: _emailController,
                      style: authInputStyle,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: cubit.emailChanged,
                      decoration: authInputDecoration(
                        errorText: state.emailError,
                      ),
                    ),














                    const SizedBox(height: AppDimensions.space20),
                    const AuthFieldLabel('Password'),
                    const SizedBox(height: AppDimensions.space8),








                    TextField(
                      key: const Key('login_password_field'),
                      controller: _passwordController,
                      style: authInputStyle,
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: cubit.passwordChanged,
                      onSubmitted: (_) => cubit.submit(),
                      decoration: authInputDecoration(
                        errorText: state.passwordError,
                        suffixIcon: IconButton(
                          key: const Key('login_obscure_toggle'),
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















                    const SizedBox(height: AppDimensions.space16),




                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Flexible so the label can wrap/shrink on wide fonts,
                        // long translations or large text scales.
                        Flexible(
                          child: GestureDetector(
                            onTap: cubit.toggleRememberMe,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                            // mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  key: const Key('login_remember_me'),
                                  value: state.rememberMe,
                                  onChanged: (_) => cubit.toggleRememberMe(),
                                ),


                               // const SizedBox(width: AppDimensions.space4),



                                const Flexible(
                                  child: Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(RoutePaths.forgotPassword),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          child: const Text('Forgot password ?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space24),



                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('login_sign_in_button'),
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
                            : const Text('Sign in'),
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
                                _showStub(context, 'Facebook sign-in'),
                          ),
                          const SizedBox(width: AppDimensions.space16),
                          SocialButton(
                            label: 'Google',
                            asset: AppAssets.googleIcon,
                            onTap: () => _showStub(context, 'Google sign-in'),
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
                            "Don't have account ?",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.gray900,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(RoutePaths.signup),
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
                            child: const Text('Sign up'),
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

///todo: EMAIL & PASSWORD ☺



//todo:email: password

