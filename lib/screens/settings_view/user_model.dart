import 'dart:convert';

class UserModel {
  final String token;
  final int id;
  final String name;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String profilePic;

  UserModel({
    required this.token,
    required this.id,
    required this.name,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
  });

  // Factory method to create an instance from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phonenumber'] ?? '',
      profilePic: json['profilepic'] ?? '',
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'name': name,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phonenumber': phoneNumber,
      'profile_pic': profilePic,
    };
  }
}

void main() {
  // Example JSON data
  const jsonString = '''
  {
      "token": "1328|xR39QWNPpthA1sUA46q4MEAHzwwhWESRSXbYps9r1e3a3542",
      "id": 260,
      "name": "siva hello",
      "role": "admin",
      "first_name": "siva",
      "last_name": "hello",
      "email": "siva2222@gmail.com",
      "phonenumber": "9951755510",
      "profile_pic": "https://uploadsmedia.s3.amazonaws.com/profile_pictures/1733734383_1200-675-19076010-thumbnail-16x9-kanguva.jpg"
  }
  ''';

  // Parsing JSON to a UserModel instance
  final user = UserModel.fromJson(json.decode(jsonString));

  // Printing user details
  print('Name: ${user.firstName} ${user.lastName}');
  print('Email: ${user.email}');
  print('Profile Picture: ${user.profilePic}');

  // Converting UserModel back to JSON
  final jsonOutput = json.encode(user.toJson());
  print('JSON Output: $jsonOutput');
}
