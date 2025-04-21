import 'package:uuid/uuid.dart';

enum JobStatus {
  inProgress,
  pending,
  approved,
}

class Job {
  final String id;
  final String jobNo;
  final String clientName;
  final String email;
  final String phoneNumber;
  final String address;
  final DateTime dateAdded;
  final JobStatus status;
  final String? assignedTo;
  final String? measurements;
  final List<String>? uploadedImages;
  final String? notes;

  Job({
    String? id,
    required this.jobNo,
    required this.clientName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.dateAdded,
    required this.status,
    this.assignedTo,
    this.measurements,
    this.uploadedImages,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Job copyWith({
    String? jobNo,
    String? clientName,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? dateAdded,
    JobStatus? status,
    String? assignedTo,
    String? measurements,
    List<String>? uploadedImages,
    String? notes,
  }) {
    return Job(
      id: this.id,
      jobNo: jobNo ?? this.jobNo,
      clientName: clientName ?? this.clientName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      dateAdded: dateAdded ?? this.dateAdded,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      measurements: measurements ?? this.measurements,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobNo': jobNo,
      'clientName': clientName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateAdded': dateAdded.toIso8601String(),
      'status': status.toString().split('.').last,
      'assignedTo': assignedTo,
      'measurements': measurements,
      'uploadedImages': uploadedImages,
      'notes': notes,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      jobNo: json['jobNo'],
      clientName: json['clientName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      dateAdded: DateTime.parse(json['dateAdded']),
      status: JobStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => JobStatus.pending,
      ),
      assignedTo: json['assignedTo'],
      measurements: json['measurements'],
      uploadedImages: json['uploadedImages'] != null
          ? List<String>.from(json['uploadedImages'])
          : null,
      notes: json['notes'],
    );
  }
}
