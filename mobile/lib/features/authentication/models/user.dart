import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phoneNumber;
  final int? dateOfBirth;
  final String? avatarUrl;
  final Gender gender;
  final int roleId;
  final Map? location;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.roleId,
    this.dateOfBirth,
    this.gender = Gender.other,
    this.avatarUrl,
    this.location
  });

  factory User.fromJson(Map json) => User(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"] ?? "",
    phoneNumber: json["phone_number"],
    dateOfBirth: json["date_of_birth"],
    avatarUrl: json["avatar_url"],
    gender: _getGenderBasedOnInt(json["gender"]),
    roleId: json["role_id"],
    location: json["location"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone_number": phoneNumber,
    "birth": dateOfBirth,
    "gender": gender,
    "avatar_url": avatarUrl,
    "role_id": roleId,
    "location": location
  };
  
  @override
  List<Object?> get props => [];
}

enum Gender {
  male, female, other
}

Gender _getGenderBasedOnInt(int? gender) {
  switch (gender) {
      case 1: return Gender.male;  
      case 2: return Gender.female;  
      default: return Gender.other;
    }
}
