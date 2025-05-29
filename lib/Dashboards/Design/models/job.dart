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
  final Map<String, dynamic>? salespersonData;

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
    this.salespersonData,
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
    Map<String, dynamic>? salespersonData,
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
      salespersonData: salespersonData ?? this.salespersonData,
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
      'salesperson': salespersonData,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    final receptionist = json['receptionist'] ?? {};
    final salesperson = json['salesperson'] ?? {};
    // Extract imageUrl from salesperson JSONB as a list
    List<String>? uploadedImages;
    if (salesperson['imageUrl'] != null) {
      if (salesperson['imageUrl'] is List) {
        uploadedImages = List<String>.from(salesperson['imageUrl']);
      } else if (salesperson['imageUrl'] is String) {
        uploadedImages = [salesperson['imageUrl']];
      }
    }
    return Job(
      id: json['id'],
      jobNo: receptionist['jobNo'] ?? '',
      clientName: receptionist['customerName'] ?? '',
      email: receptionist['email'] ?? '',
      phoneNumber: receptionist['phone'] ?? '',
      address: receptionist['address'] ?? '',
      dateAdded: DateTime.parse(json['created_at']),
      status: JobStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => JobStatus.pending,
      ),
      assignedTo: null, // Update if needed
      measurements: null, // Update if needed
      uploadedImages: uploadedImages,
      notes: null, // Update if needed
      salespersonData: Map<String, dynamic>.from(salesperson),
    );
  }
}
