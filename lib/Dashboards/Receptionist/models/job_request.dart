import 'package:uuid/uuid.dart';

enum JobRequestStatus { approved, declined, pending }

class JobRequest {
  final String id;
  final String name;
  final String phone;
  final String email;
  final JobRequestStatus status;
  final DateTime? dateAdded;
  final String? subtitle;
  final String? avatar;
  final String? time;
  final bool? assigned;

  JobRequest({
    String? id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    this.dateAdded,
    this.subtitle,
    this.avatar,
    this.time,
    this.assigned,
  }) : id = id ?? const Uuid().v4();

  factory JobRequest.fromMap(Map<String, dynamic> map) {
    return JobRequest(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      status: JobRequestStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (map['status']?.toLowerCase() ?? 'pending'),
        orElse: () => JobRequestStatus.pending,
      ),
      dateAdded: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      subtitle: map['subtitle'],
      avatar: map['avatar'],
      time: map['time'],
      assigned: map['assigned'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'status': status.name,
        'date': dateAdded?.toIso8601String(),
        'subtitle': subtitle,
        'avatar': avatar,
        'time': time,
        'assigned': assigned,
      };
}

class ReceptionistJob {
  final String id;
  final String name;
  final String subtitle;
  final String avatar;
  final String location;

  ReceptionistJob({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.location,
  });

  factory ReceptionistJob.fromMap(Map<String, dynamic> map) {
    return ReceptionistJob(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      avatar: map['avatar'] ?? '',
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'avatar': avatar,
        'location': location,
      };
}
