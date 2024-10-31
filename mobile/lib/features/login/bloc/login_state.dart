import 'package:equatable/equatable.dart';

enum LoginStatus { inProcess, success, fail, init }

final class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.init,
    this.phoneNumber = "",
    this.password = "",
    this.isValid = false,
  });

  final LoginStatus status;
  final String phoneNumber;
  final String password;
  final bool isValid;

  LoginState copyWith({
    LoginStatus? status,
    String? phoneNumber,
    String? password,
    bool? isValid,
  }) {
    return LoginState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, phoneNumber, password];
}