import 'package:uuid/uuid.dart';

enum SalespersonStatus { available, onVisit, busy, away }

class Salesperson {
  final String id;
  final String name;
  final SalespersonStatus status;
  final String? avatar;
  final String? subtitle;
  final String department;
  final List<String> expertise;
  final List<String> skills;
  final int currentWorkload; // e.g., number of active tasks or a percentage

  Salesperson({
    String? id,
    required this.name,
    required this.status,
    this.avatar,
    this.subtitle,
    required this.department,
    this.expertise = const [],
    this.skills = const [],
    this.currentWorkload = 0,
  }) : id = id ?? const Uuid().v4();

  factory Salesperson.fromJson(Map<String, dynamic> json) {
    return Salesperson(
      id: json['id'] as String?,
      name: json['name'] as String,
      status: SalespersonStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['status']?.toString().toLowerCase() ?? 'available'),
        orElse: () => SalespersonStatus.available,
      ),
      avatar: json['avatar'] as String?,
      subtitle: json['subtitle'] as String?,
      department: json['department'] as String? ?? 'Unknown Department',
      expertise: json['expertise'] != null ? List<String>.from(json['expertise'] as List) : [],
      skills: json['skills'] != null ? List<String>.from(json['skills'] as List) : [],
      currentWorkload: json['currentWorkload'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.name,
        'avatar': avatar,
        'subtitle': subtitle,
        'department': department,
        'expertise': expertise,
        'skills': skills,
        'currentWorkload': currentWorkload,
      };
}
