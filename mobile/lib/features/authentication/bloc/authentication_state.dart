import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:equatable/equatable.dart';

enum AuthenticationStatus { unknown, authorized, unauthorized, loading, error }

class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.unknown,
    this.user
  });

  final AuthenticationStatus status;
  final User? user;

  AuthenticationState copyWith({
    required AuthenticationStatus status,
    User? user
  }) {
    return AuthenticationState(
      status: status,
      user: user
    );
  }

  @override
  List<Object> get props => [status];
}
