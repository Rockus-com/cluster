// user_model.dart
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePic;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePic,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      profilePic: json['profile_pic'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'profile_pic': profilePic,
      'created_at': createdAt.toIso8601String(),
    };
  }
}