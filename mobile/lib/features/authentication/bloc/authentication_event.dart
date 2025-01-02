import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthSubscription extends AuthenticationEvent {}

class LogoutRequest extends AuthenticationEvent {}

class DeleteAccount extends AuthenticationEvent {}

class AutoLogin extends AuthenticationEvent {}

class UpdateInfo extends AuthenticationEvent {
  final User user;

  UpdateInfo(this.user);

  @override
  List<Object> get props => [user];
}


