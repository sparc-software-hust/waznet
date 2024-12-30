import 'package:bloc/bloc.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_event.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_state.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/authentication/repository/authentication_repository.dart';
import 'package:cecr_unwomen/features/user/repository/user_repository.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationState()) {
    on<AuthSubscription>(_onAuthSubscription);
    on<LogoutRequest>(_onLogoutRequest);
    on<AutoLogin>(_onAutoLogin);
    on<UpdateInfo>(_onUpdateInfo);
  }

  Future<void> _onAuthSubscription(AuthSubscription event, Emitter emit) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));
    await emit.onEach(AuthRepository.status,
      onData: (AuthenticationStatus status) async {
        switch (status) {
          case AuthenticationStatus.authorized:
            final Map? userMap = await UserRepository.getUserDataFromPrefs();
            if (userMap == null) emit(state.copyWith(status: AuthenticationStatus.unauthorized));

            final User user = User.fromJson(userMap!);
            return emit(state.copyWith(status: AuthenticationStatus.authorized, user: user));
          case AuthenticationStatus.unauthorized:
            return emit(state.copyWith(status: AuthenticationStatus.unauthorized));
          default:
            return emit(state.copyWith(status: AuthenticationStatus.error));
        }
      },
      onError: (e, t) {
        print('gndkjffdg:$e $t');
        emit(state.copyWith(status: AuthenticationStatus.error));
      }
    );
  }

  void _onLogoutRequest(LogoutRequest event, Emitter emit) {
    AuthRepository.logout();
  }

  Future<void> _onAutoLogin(AutoLogin event, Emitter emit) async {
    try {
      final bool loggedIn = await AuthRepository.checkUserLoggedIn();
      if (!loggedIn) {
        await AuthRepository.logoutNoCredentials();
        emit(state.copyWith(status: AuthenticationStatus.unauthorized));
        return;
      }

      final Map? userMap = await UserRepository.getUserDataFromPrefs();
      if (userMap == null) emit(state.copyWith(status: AuthenticationStatus.unauthorized));

      final User user = User.fromJson(userMap!);
      emit(state.copyWith(status: AuthenticationStatus.authorized, user: user));
    } catch (e) {
      print('gndfkj:$e');
      emit(state.copyWith(status: AuthenticationStatus.error));
    }
  }

  Future<void> _onUpdateInfo(UpdateInfo event, Emitter emit) async {
    try {
      emit(state.copyWith(status: AuthenticationStatus.authorized, user: event.user));
    } catch (e) {
      print('udpate into :$e');
      emit(state.copyWith(status: AuthenticationStatus.error));
    }
  }
}
