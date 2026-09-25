import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/request_status.dart';
import '../../../core/error/failure_mapper.dart';
import '../repositories/profile_repository.dart';
import 'profile_state.dart';

/// ViewModel of the Profile tab.
///
/// Loads the account once per visit; menu taps and sign-out are pure
/// navigation/stubs in the View, so they stay out of the ViewModel.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileState());

  final ProfileRepository _profileRepository;

  Future<void> load() async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      clearFailure: true,
    ));
    try {
      final profile = await _profileRepository.getProfile();
      emit(state.copyWith(status: RequestStatus.success, profile: profile));
    } catch (error) {
      emit(state.copyWith(
        status: RequestStatus.failure,
        failure: FailureMapper.map(error),
      ));
    }
  }
}
