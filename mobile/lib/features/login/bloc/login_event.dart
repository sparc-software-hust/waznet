abstract class LoginEvent {}

class LoginPhoneNumberChanged extends LoginEvent {
  final String phoneNumber;
  LoginPhoneNumberChanged({required this.phoneNumber});
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged({required this.password});
}

class LoginSubmitted extends LoginEvent {}

