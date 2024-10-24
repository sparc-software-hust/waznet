import 'package:bloc/bloc.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_event.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_state.dart';
import 'package:cecr_unwomen/features/authentication/repository/authentication_repository.dart';
import 'package:cecr_unwomen/models/credential.dart';
import 'package:cecr_unwomen/models/user.dart';
import 'package:flutter/foundation.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationState()) {
    on<LogInRequest>(_onLoginRequest);
    on<LogoutRequest>(_onLogoutRequest);
    on<CheckAutoLogin>(_onCheckAutoLogin);
    on<Update>(_onUpdate);
  }

  void _onUpdate(Update event, Emitter emit) async {
    await AuthRepository.logoutNoCredentials();
    emit(state.copyWith(status: AuthenticationStatus.unauthorized, credential: Credential.empty));
  }

  void _onLoginRequest(LogInRequest event, Emitter emit) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));
    try {
      final Map response = await AuthRepository.login(event.email, event.password);
      final bool isLoginSuccess = response["success"];

      if (!isLoginSuccess) {
        await AuthRepository.logoutNoCredentials();
        emit(state.copyWith(status: AuthenticationStatus.unauthorized, credential: Credential.empty));
        return;
      }
      final Map data = response["data"];
      await AuthRepository.saveTokenDataIntoPrefs(data);
      await AuthRepository.saveUserDataIntoPrefs(data["user"]);
      emit(state.copyWith(
        status: AuthenticationStatus.authorized,
        credential: Credential.fromJson(data)
      ));
    } catch (e) {
      debugPrint("eerror login:$e");
      emit(state.copyWith(status: AuthenticationStatus.error));
    }
  }

  void _onLogoutRequest(LogoutRequest event, Emitter emit) async {
    try {
      await AuthRepository.logoutNoCredentials();
      emit(state.copyWith(status: AuthenticationStatus.unauthorized, credential: Credential.empty));
    } catch (e) {
      emit(state.copyWith(status: AuthenticationStatus.error));
    }
  }

  void _onCheckAutoLogin(CheckAutoLogin event, Emitter emit) async {
    try {
      final bool loggedIn = await AuthRepository.checkUserLoggedIn();
      if (!loggedIn) {
        await AuthRepository.logoutNoCredentials();
        emit(state.copyWith(status: AuthenticationStatus.unauthorized, credential: Credential.empty));
        return;
      }
      final List tokenData = await AuthRepository.getTokenDataFromPrefs();
      final Map userPrefs = await AuthRepository.getUserDataFromPrefs() ?? {};
      final User user = User.fromJson(userPrefs);

      emit(state.copyWith(
        status: AuthenticationStatus.authorized,
        credential: Credential(
          accessToken: tokenData[0],
          refreshToken: tokenData[1],
          accessExp: tokenData[2],
          user: user
        )
      ));
    } catch (e, t) {
      print('dgndfgj:$e $t');
      emit(state.copyWith(status: AuthenticationStatus.error));
    }
  }
}
