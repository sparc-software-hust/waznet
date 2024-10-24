import 'package:cecr_unwomen/models/user.dart';
import 'package:equatable/equatable.dart';

class Credential extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int accessExp;
  final User? user;

  const Credential({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExp,
    this.user
  });
  
  @override
  List<Object?> get props => [accessToken, refreshToken, accessExp];

  static const empty = Credential(accessToken: "", refreshToken: "", accessExp: 0);

  static Credential fromJson(Map data) {
    final Credential credentials = Credential(
      accessToken: data["access_token"] ?? "", 
      refreshToken: data["refresh_token"] ?? "", 
      accessExp: data["access_exp"] ?? 0,
      user: User.fromJson(data["user"])
    );
    return credentials;
  }
}