import 'package:uuid/uuid.dart';

enum SalespersonStatus { available, onVisit, busy, away }

class Salesperson {
  final String id;
  final String name;
  final SalespersonStatus status;
  final String? avatar;
  final String? subtitle;

  Salesperson({
    String? id,
    required this.name,
    required this.status,
    this.avatar,
    this.subtitle,
  }) : id = id ?? const Uuid().v4();

  factory Salesperson.fromJson(Map<String, dynamic> json) {
    return Salesperson(
      id: json['id'],
      name: json['name'],
      status: SalespersonStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['status']?.toLowerCase() ?? 'available'),
        orElse: () => SalespersonStatus.available,
      ),
      avatar: json['avatar'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status.name,
        'avatar': avatar,
        'subtitle': subtitle,
      };
}
