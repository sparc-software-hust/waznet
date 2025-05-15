import 'package:equatable/equatable.dart';

enum ProgressStatus {
  inProcess,
  success,
  fail,
  notAuthenticated,
  onLogin,
  authenticated,
  init
}

enum PasswordStatus { notValid, notMatch, sameAsOld, init, valid }

final class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ProgressStatus.init,
    this.passwordStatus = PasswordStatus.init,
    this.password = "",
  });

  final ProgressStatus status;
  final String password;
  final PasswordStatus passwordStatus;

  ChangePasswordState copyWith({
    ProgressStatus? status,
    PasswordStatus? passwordStatus,
    String? password,
  }) {
    return ChangePasswordState(
        status: status ?? this.status,
        password: password ?? this.password,
        passwordStatus: passwordStatus ?? this.passwordStatus);
  }

  @override
  List<Object> get props => [status, password, passwordStatus];
}
