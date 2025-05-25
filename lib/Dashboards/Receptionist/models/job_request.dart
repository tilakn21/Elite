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

  factory JobRequest.fromJson(Map<String, dynamic> json) {
    return JobRequest(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      status: JobRequestStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['status']?.toLowerCase() ?? 'pending'),
        orElse: () => JobRequestStatus.pending,
      ),
      dateAdded: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      subtitle: json['subtitle'],
      avatar: json['avatar'],
      time: json['time'],
      assigned: json['assigned'],
    );
  }

  Map<String, dynamic> toJson() => {
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

  factory ReceptionistJob.fromJson(Map<String, dynamic> json) {
    return ReceptionistJob(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      avatar: json['avatar'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'avatar': avatar,
        'location': location,
      };
}
