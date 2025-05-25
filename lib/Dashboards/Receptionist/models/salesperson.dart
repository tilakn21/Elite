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

  factory Salesperson.fromMap(Map<String, dynamic> map) {
    return Salesperson(
      id: map['id'],
      name: map['name'],
      status: SalespersonStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (map['status']?.toLowerCase() ?? 'available'),
        orElse: () => SalespersonStatus.available,
      ),
      avatar: map['avatar'],
      subtitle: map['subtitle'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status.name,
        'avatar': avatar,
        'subtitle': subtitle,
      };
}
