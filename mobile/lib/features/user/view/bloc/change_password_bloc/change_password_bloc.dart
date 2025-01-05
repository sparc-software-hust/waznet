import 'package:cecr_unwomen/features/authentication/repository/authentication_repository.dart';
import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:cecr_unwomen/features/user/view/bloc/change_password_bloc/change_password_event.dart';
import 'package:cecr_unwomen/features/user/view/bloc/change_password_bloc/change_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(const ChangePasswordState()) {
    on<CheckPassWord>(_onLoginSubmitted);
    on<OnTypePassword>(_onTypePassword);
    on<OnTypeNewPassword>(_onTypeNewPassword);
    on<OnTypeConfirmPassword>(_onTypeConfirmPassword);
    on<OnSubmitted>(_onSubmitted);
  }

  void _onLoginSubmitted(CheckPassWord event, Emitter emit) async {
    try {
      final bool isSuccess =
          await AuthRepository.checkPassword(event.phoneNumber, state.password);
      if (!isSuccess) {
        emit(state.copyWith(status: ProgressStatus.notAuthenticated));
        return;
      }
      emit(state.copyWith(status: ProgressStatus.authenticated));
    } catch (_) {
      emit(state.copyWith(status: ProgressStatus.notAuthenticated));
    }
  }

  void _onTypePassword(OnTypePassword event, Emitter emit) async {
    if (event.password.length < 8) {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.notValid));
    } else {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.init));
    }
  }

  void _onTypeNewPassword(OnTypeNewPassword event, Emitter emit) async {
    if (event.password.length < 8) {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.notValid));
    } else if (event.password == event.oldPassword) {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.sameAsOld));
    } else {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.init));
    }
  }

  void _onTypeConfirmPassword(OnTypeConfirmPassword event, Emitter emit) async {
    if (event.confirmPassword.length < 8) {
      emit(state.copyWith(
          password: event.confirmPassword,
          passwordStatus: PasswordStatus.notValid));
    }
    if (event.confirmPassword != event.password) {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.notMatch));
    }
    if (event.confirmPassword == event.password && event.confirmPassword.length >= 8) {
      emit(state.copyWith(
          password: event.password, passwordStatus: PasswordStatus.valid));
    }
  }

  void _onSubmitted(OnSubmitted event, Emitter emit) async {
    try {
      final res =
          await UserApi.changePassword(event.newPassword, event.oldPassword);
      bool isSuccess = res["success"];
      if (isSuccess) {
        await AuthRepository.saveTokenDataIntoPrefs(res["data"]);
        event.callback.call(true);
        emit(state.copyWith(status: ProgressStatus.success));
      } else {
        event.callback.call(false);
        emit(state.copyWith(status: ProgressStatus.fail));
      }
    } catch (_) {
      emit(state.copyWith(status: ProgressStatus.fail));
    }
  }
}
