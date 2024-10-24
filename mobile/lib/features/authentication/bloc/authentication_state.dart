import 'package:cecr_unwomen/models/credential.dart';
import 'package:equatable/equatable.dart';

enum AuthenticationStatus { unknown, authorized, unauthorized, loading, error }

class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.credential = Credential.empty,
    this.status = AuthenticationStatus.unknown
  });

  final Credential credential;
  final AuthenticationStatus status;

  AuthenticationState copyWith({
    required AuthenticationStatus status,
    Credential? credential,
  }) {
    return AuthenticationState(
      status: status,
      credential: credential ?? this.credential,
    );
  }

  @override
  List<Object> get props => [credential, status];
}
