import 'package:flutter/foundation.dart'; // For kDebugMode if needed for print statements

// Model for a production job (for job list, job table, job status, etc.)
class ProductionJob {
  final String id; // Added ID
  final String jobNo;
  final String clientName;
  final DateTime dueDate; // Changed to DateTime
  final String description;
  final JobStatus status;
  final String? action; // Assuming action can be nullable or clarify its purpose
  // Consider adding fields like assignedWorkers (List<Worker>), materials (List<Material>), progress (double) etc. if relevant

  ProductionJob({
    required this.id,
    required this.jobNo,
    required this.clientName,
    required this.dueDate,
    required this.description,
    required this.status,
    this.action,
  });

  // Factory constructor to create a ProductionJob from JSON
  factory ProductionJob.fromJson(Map<String, dynamic> json) {
    return ProductionJob(
      id: json['id'] as String,
      jobNo: json['jobNo'] as String,
      clientName: json['clientName'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      description: json['description'] as String,
      status: JobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () {
          // Fallback for unknown status, could log or throw error
          if (kDebugMode) {
            print('Warning: Unknown JobStatus "${json['status']}" received from API. Defaulting to pending.');
          }
          return JobStatus.pending; 
        },
      ),
      action: json['action'] as String?,
    );
  }

  // Method to convert a ProductionJob instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobNo': jobNo,
      'clientName': clientName,
      'dueDate': dueDate.toIso8601String(),
      'description': description,
      'status': status.name, // Convert enum to string (its name)
      'action': action,
    };
  }

  // Optional: copyWith method for easier updates
  ProductionJob copyWith({
    String? id,
    String? jobNo,
    String? clientName,
    DateTime? dueDate,
    String? description,
    JobStatus? status,
    String? action,
  }) {
    return ProductionJob(
      id: id ?? this.id,
      jobNo: jobNo ?? this.jobNo,
      clientName: clientName ?? this.clientName,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      status: status ?? this.status,
      action: action ?? this.action,
    );
  }
}

enum JobStatus {
  inProgress,
  processedForPrinting,
  completed,
  onHold,
  pending,
}

extension JobStatusExtension on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.inProgress:
        return 'In progress';
      case JobStatus.processedForPrinting:
        return 'Processed for printing';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.onHold:
        return 'On hold';
      case JobStatus.pending:
        return 'Pending';
    }
  }
}
