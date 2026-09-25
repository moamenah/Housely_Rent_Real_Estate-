import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/request_status.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/views/widgets/auth_cta_button.dart';
import '../../auth/views/widgets/auth_field.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import '../viewmodels/edit_profile_cubit.dart';
import '../viewmodels/edit_profile_state.dart';
import 'widgets/profile_avatar.dart';

/// The editing form — portrait, four fields, *Save Change*.
///
/// Text fields are controller-driven (they must pre-fill from the loaded
/// account but stay uncontrolled while typing); the date of birth is a
/// read-only row that opens the platform date picker, so its value lives in
/// state instead of a controller.
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key, required this.profileRepository});

  /// Injected by the router so the View never touches the service locator.
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(profileRepository: profileRepository)
        ..load(),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Runs once, when the account arrives: afterwards the controllers own the
  /// text, while state owns only validation and the date.
  void _prefillFrom(EditProfileState state) {
    if (_prefilled || state.profile == null) return;
    _nameController.text = state.name;
    _usernameController.text = state.username;
    _emailController.text = state.email;
    _prefilled = true;
  }

  Future<void> _pickDate(BuildContext context, EditProfileState state) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateOfBirth ??
          DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      this.context.read<EditProfileCubit>().dateOfBirthChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) =>
          previous.loadStatus != current.loadStatus ||
          previous.saveStatus != current.saveStatus,
      listener: (context, state) {
        if (state.loadStatus == RequestStatus.success) {
          _prefillFrom(state);
        } else if (state.loadStatus == RequestStatus.failure) {
          context.showSnack(
            state.failure?.message ?? 'We could not load your profile.',
            isError: true,
          );
        }

        if (state.isSaved) {
          FocusManager.instance.primaryFocus?.unfocus();
          context.showSnack('Your profile has been updated.');
          context.goBackTo(RoutePaths.profile);
        } else if (state.saveFailed) {
          // Field problems render inline; only transport/policy failures
          // land here as a banner.
          context.showSnack(
            state.failure?.message ?? 'We could not save your profile.',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<EditProfileCubit>();

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space8,
                    AppDimensions.space4,
                    AppDimensions.space8,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('edit_profile_back_button'),
                        onPressed: () =>
                            context.goBackTo(RoutePaths.profile),
                        icon: const Icon(Icons.arrow_back_outlined),
                        color: AppColors.gray900,
                        iconSize: 26,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Edit Profile',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48, height: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: state.profile == null
                      ? state.loadFailed
                          ? ErrorView(
                              message: state.failure?.message ??
                                  'We could not load your profile.',
                              onRetry: cubit.load,
                            )
                          : const Padding(
                              padding:
                                  EdgeInsets.only(top: AppDimensions.space64),
                              child: AppLoadingIndicator(),
                            )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.pagePadding,
                            AppDimensions.space16,
                            AppDimensions.pagePadding,
                            AppDimensions.space24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: ProfileAvatar(
                                  key: const Key('edit_profile_avatar'),
                                  name: state.name.trim().isEmpty
                                      ? state.profile!.name
                                      : state.name,
                                  size: 150,
                                  onTap: () => context.showSnack(
                                    "Changing your photo isn't available "
                                    'in this build yet.',
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              const AuthFieldLabel('Full Name'),
                              const SizedBox(height: AppDimensions.space8),
                              TextField(
                                key: const Key('edit_profile_name_field'),
                                controller: _nameController,
                                style: authInputStyle,
                                textInputAction: TextInputAction.next,
                                onChanged: cubit.nameChanged,
                                decoration: authInputDecoration(
                                  errorText: state.nameError,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space20),
                              const AuthFieldLabel('Username'),
                              const SizedBox(height: AppDimensions.space8),
                              TextField(
                                key: const Key('edit_profile_username_field'),
                                controller: _usernameController,
                                style: authInputStyle,
                                textInputAction: TextInputAction.next,
                                onChanged: cubit.usernameChanged,
                                decoration: authInputDecoration(
                                  errorText: state.usernameError,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space20),
                              const AuthFieldLabel('Email'),
                              const SizedBox(height: AppDimensions.space8),
                              TextField(
                                key: const Key('edit_profile_email_field'),
                                controller: _emailController,
                                style: authInputStyle,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: cubit.emailChanged,
                                decoration: authInputDecoration(
                                  errorText: state.emailError,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space20),
                              const AuthFieldLabel('Date of birth'),
                              const SizedBox(height: AppDimensions.space8),
                              _DateOfBirthField(
                                state: state,
                                onTap: () => _pickDate(context, state),
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              AuthCtaButton(
                                label: 'Save Change',
                                buttonKey:
                                    const Key('edit_profile_save_button'),
                                isLoading: state.isSaving,
                                onPressed: () {
                                  FocusManager.instance.primaryFocus
                                      ?.unfocus();
                                  cubit.save();
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Read-only field that shows the chosen date and opens the date picker.
class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({required this.state, required this.onTap});

  final EditProfileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = state.dateOfBirthError != null;
    // The picked value lives in state — it must win over the loaded snapshot
    // as soon as the user chooses a new date.
    final dateOfBirth = state.dateOfBirth ?? state.profile?.dateOfBirth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('edit_profile_dob_field'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space16,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateOfBirth == null
                        ? 'Not set'
                        : Profile.formatDateOfBirth(dateOfBirth),
                    style: authInputStyle,
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: AppDimensions.iconLg,
                  color: AppColors.gray900,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.space4),
            child: Text(
              state.dateOfBirthError!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
