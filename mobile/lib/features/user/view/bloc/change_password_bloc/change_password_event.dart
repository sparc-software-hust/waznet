abstract class ChangePasswordEvent {}

class CheckPassWord extends ChangePasswordEvent {
  final String phoneNumber;

  CheckPassWord({required this.phoneNumber});
}

class OnTypePassword extends ChangePasswordEvent {
  final String password;

  OnTypePassword({required this.password});
}

class OnTypeNewPassword extends ChangePasswordEvent {
  final String password;
  final String oldPassword;

  OnTypeNewPassword({required this.password, required this.oldPassword});
}

class OnTypeConfirmPassword extends ChangePasswordEvent {
  final String password;
  final String confirmPassword;

  OnTypeConfirmPassword(
      {required this.password, required this.confirmPassword});
}

class OnSubmitted extends ChangePasswordEvent {
  final String newPassword;
  final String oldPassword;
  final Function(bool) callback;

  OnSubmitted({required this.newPassword, required this.oldPassword, required this.callback});
}
