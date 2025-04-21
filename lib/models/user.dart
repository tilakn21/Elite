import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final bool isActive;

  User({
    String? id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  User copyWith({
    String? name,
    String? email,
    String? avatar,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
    );
  }
}
