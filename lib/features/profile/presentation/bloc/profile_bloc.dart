import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/profile/domain/usecases/get_current_user_usecase.dart';
// Import other usecases...
import 'package:inventory_tsth2/features/profile/presentation/bloc/profile_event.dart';
import 'package:inventory_tsth2/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUsecase getCurrentUser;
  // final UpdateUserProfileUsecase updateUserProfile;
  // final UpdateAvatarUsecase updateAvatar;
  // final ChangePasswordUsecase changePassword;

  ProfileBloc({
    required this.getCurrentUser,
    // required this.updateUserProfile,
    // required this.updateAvatar,
    // required this.changePassword,
  }) : super(ProfileInitial()) {
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UpdateProfileDetailsEvent>(_onUpdateProfileDetails);
    // Register other event handlers here
  }

  Future<void> _onGetCurrentUser(GetCurrentUserEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final failureOrUser = await getCurrentUser(NoParams());
    failureOrUser.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfileDetails(UpdateProfileDetailsEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileActionInProgress());
    // final failureOrUser = await updateUserProfile(event.user);
    // failureOrUser.fold(
    //   (failure) => emit(ProfileActionFailure(failure.message)),
    //   (user) {
    //     emit(const ProfileActionSuccess("Profil berhasil diperbarui"));
    //     add(GetCurrentUserEvent()); // Refresh profile data
    //   },
    // );
  }
  
  // Implement other event handlers (_onUpdateAvatar, _onChangePassword)
}