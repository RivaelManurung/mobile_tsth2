import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/usecases/login_user_usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/usecases/logout_user.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_event.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final LoginUserUsecase loginUserUsecase;
  final LogoutUserUsecase logoutUserUsecase;

  UserBloc({
    required this.loginUserUsecase,
    required this.logoutUserUsecase,
  }) : super(UserInitial()) {
    on<LoginUserEvent>(_onUserLogin);
    on<UserLogoutEvent>(_onUserLogout);
  }

  Future<void> _onUserLogin(
    LoginUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoggingIn());
    final failureOrUser = await loginUserUsecase(
      LoginParams(name: event.name, password: event.password),
    );

    failureOrUser.fold(
      (failure) => emit(UserLoggedInError(failure.message)),
      (user) => emit(UserLoggedIn(user: user)),
    );
  }

  Future<void> _onUserLogout(
    UserLogoutEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLogoutLoading());
    final failureOrUnit = await logoutUserUsecase(NoParams());
    failureOrUnit.fold(
      (failure) => emit(UserLoggedOutError(failure.message)),
      (_) => emit(const UserLoggedOut('Logout successful!')),
    );
  }
}