import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final Gender gender;
  final int roleId;
  final String? location;
  final DateTime? timeReminded;
  final  DateTime? insertedAt;

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
    this.location,
    this.timeReminded,
    this.insertedAt
  });

  factory User.fromJson(Map json) => User(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"] ?? "",
    phoneNumber: json["phone_number"],
    dateOfBirth: json["date_of_birth"] != null 
      ? DateTime.tryParse(json["date_of_birth"]) 
      : null,
    avatarUrl: json["avatar_url"],
    gender: getGenderBasedOnInt(json["gender"]),
    roleId: json["role_id"],
    location: json["location"],
    timeReminded: json["time_reminded"] != null 
      ? DateTime.tryParse(json["time_reminded"]) 
      : null,
    insertedAt: json["inserted_at"] != null 
      ? DateTime.tryParse(json["inserted_at"]) 
      : null,
    
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone_number": phoneNumber,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "gender": convertGenderToInt(gender),
    "avatar_url": avatarUrl,
    "role_id": roleId,
    "location": location,
    "time_reminded": timeReminded?.toIso8601String(),
    "inserted_at": insertedAt?.toIso8601String()
  };

  User clone(Map data) => User.fromJson(data);

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatarUrl,
    Gender? gender,
    int? roleId,
    String? location,
    DateTime? timeReminded,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      roleId: roleId ?? this.roleId,
      location: location ?? this.location,
      timeReminded: timeReminded ?? this.timeReminded
    );
  }

  
  @override
  List<Object?> get props => [
    id, firstName, lastName, email, phoneNumber, dateOfBirth, avatarUrl, gender, roleId, location, timeReminded
  ];
}

enum Gender {
  male, female, other
}

int convertGenderToInt(Gender gender) {
  switch (gender) {
      case Gender.male: return 1;
      case Gender.female: return 2;
      default: return 0;
    }
}

Gender getGenderBasedOnInt(int? gender) {
  switch (gender) {
      case 1: return Gender.male;
      case 2: return Gender.female;
      default: return Gender.other;
  }
}

String convertGenderToString(Gender gender) {
    switch (gender) {
      case Gender.male: return "Nam";
      case Gender.female: return "Nữ";
      default: return "Không xác định";
    }
}
