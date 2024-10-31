import 'package:bloc/bloc.dart';
import 'package:cecr_unwomen/features/authentication/repository/authentication_repository.dart';
import 'package:cecr_unwomen/features/login/bloc/login_event.dart';
import 'package:cecr_unwomen/features/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState>{
  LoginBloc() : super(const LoginState()) {
    on<LoginPhoneNumberChanged>(_onLoginPhoneNumberChanged);
    on<LoginPasswordChanged>(_onLoginPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  void _onLoginPhoneNumberChanged(LoginPhoneNumberChanged event, Emitter emit) {
    final String phoneNumber = event.phoneNumber;
    emit(
      state.copyWith(
        phoneNumber: phoneNumber,
        isValid: _validatePhoneNumber(phoneNumber)
      ),
    );
  }

  void _onLoginPasswordChanged(LoginPasswordChanged event, Emitter emit) {
    final String password = event.password;
    emit(
      state.copyWith(
        password: password,
        isValid: _validatePassword(password)
      ),
    );
  } 

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: LoginStatus.inProcess));
    try {
      await AuthRepository.login(state.phoneNumber, state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.fail));
    }
  }

  bool _validatePhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10;
  }

  bool _validatePassword(String pass) {
    return pass.length >= 8;
  }
}