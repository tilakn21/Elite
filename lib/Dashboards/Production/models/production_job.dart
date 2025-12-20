enum JobStatus {
  received,
  assignedLabour,
  inProgress, // Will be displayed as 'Forwarded for printing'
  processedForPrinting,
  completed,
  onHold,
  pending,
  printingCompleted, // Added for printing completed status
}

extension JobStatusExtension on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.received:
        return 'received';
      case JobStatus.assignedLabour:
        return 'Assigned Labour';
      case JobStatus.inProgress:
        return 'Forwarded for printing';
      case JobStatus.processedForPrinting:
        return 'Forwarded for printing';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.onHold:
        return 'On hold';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.printingCompleted:
        return 'Printing Completed';
    }
  }

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return JobStatus.received;
      case 'assigned_labour':
        return JobStatus.assignedLabour;
      case 'in_progress':
      case 'printing':
      case 'forwarded for printing':
      case 'processed_for_printing':
        return JobStatus.inProgress;
      case 'completed':
      case 'production_complete':
        return JobStatus.completed;
      case 'on_hold':
        return JobStatus.onHold;
      case 'printing_completed':
        return JobStatus.printingCompleted;
      case 'pending':
      default:
        return JobStatus.pending;
    }
  }
}

// Model for a production job (for job list, job table, job status, etc.)
class ProductionJob {
  final String id; // Added ID
  final String jobNo;
  final String clientName;
  final DateTime dueDate; // Changed to DateTime
  final String description;
  final JobStatus status;
  final String? action; // Assuming action can be nullable or clarify its purpose
  final Map<String, dynamic>? receptionistjsonb;
  final Map<String, dynamic>? salespersonjsonb;
  final Map<String, dynamic>? designjsonb;
  final Map<String, dynamic>? accountsjsonb;
  final Map<String, dynamic>? productionjsonb;
  ProductionJob({
    required this.id,
    required this.jobNo,
    required this.clientName,
    required this.dueDate,
    required this.description,
    required this.status,
    this.action,
    this.receptionistjsonb,
    this.salespersonjsonb,
    this.designjsonb,
    this.accountsjsonb,
    this.productionjsonb,
  });
  factory ProductionJob.fromJson(Map<String, dynamic> json) {
    final receptionistData = (json['receptionist'] as Map<String, dynamic>?) ?? {};
    final salespersonData = (json['salesperson'] as Map<String, dynamic>?) ?? {};
    
    // Handle design data which could be a List or Map
    Map<String, dynamic> designData = {};
    final rawDesignData = json['design'];
    if (rawDesignData != null) {
      if (rawDesignData is List) {
        // Get the latest design if we have multiple design submissions
        if (rawDesignData.isNotEmpty) {
          final latestDesign = rawDesignData.last;
          if (latestDesign is Map<String, dynamic>) {
            designData = Map<String, dynamic>.from(latestDesign);
          }
        }
      } else if (rawDesignData is Map<String, dynamic>) {
        designData = Map<String, dynamic>.from(rawDesignData);
      }
    }

    // Handle production data
    final productionData = (json['production'] as Map<String, dynamic>?) ?? {};

    // Get the customer name from receptionist data
    final customerName = (receptionistData['customerName'] as String?) ?? 'N/A';

    // Get due date with fallback to created_at
    final dueDate = DateTime.tryParse(salespersonData['dateOfSubmission'] as String? ?? '') ?? 
               DateTime.parse((json['created_at'] as String?) ?? DateTime.now().toIso8601String());

    // Get status from production JSONB field instead of main status column
    String statusString;
    if (productionData.isNotEmpty && productionData['current_status'] != null) {
      statusString = productionData['current_status'] as String;
    } else {
      // Fallback to main status column if production status is not available
      statusString = (json['status'] as String?) ?? 'pending';
    }

    return ProductionJob(
      id: (json['id'] as Object).toString(),
      jobNo: (json['job_code'] != null && json['job_code'].toString().trim().isNotEmpty && json['job_code'].toString().toLowerCase() != 'null')
          ? json['job_code'].toString()
          : (json['id'] as Object).toString(),
      clientName: customerName,
      dueDate: dueDate,
      description: (designData['comments'] as String?) ?? (designData['description'] as String?) ?? 'No description',
      status: _getJobStatus(statusString),
      action: _getActionForStatus(statusString),
      receptionistjsonb: receptionistData,
      salespersonjsonb: salespersonData,
      designjsonb: designData,
      accountsjsonb: json['accountant'] as Map<String, dynamic>?,
      productionjsonb: productionData,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobNo': jobNo,
      'clientName': clientName,
      'dueDate': dueDate.toIso8601String(),
      'description': description,
      'status': status.name, // Convert enum to string (its name)
      'action': action,
      'receptionistjsonb': receptionistjsonb,
      'salespersonjsonb': salespersonjsonb,
      'designjsonb': designjsonb,
      'accountsjsonb': accountsjsonb,
      'productionjsonb': productionjsonb,
    };
  }
  ProductionJob copyWith({
    String? id,
    String? jobNo,
    String? clientName,
    DateTime? dueDate,
    String? description,
    JobStatus? status,
    String? action,
    Map<String, dynamic>? receptionistjsonb,
    Map<String, dynamic>? salespersonjsonb,
    Map<String, dynamic>? designjsonb,
    Map<String, dynamic>? accountsjsonb,
    Map<String, dynamic>? productionjsonb,
  }) {
    return ProductionJob(
      id: id ?? this.id,
      jobNo: jobNo ?? this.jobNo,
      clientName: clientName ?? this.clientName,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      status: status ?? this.status,
      action: action ?? this.action,
      receptionistjsonb: receptionistjsonb ?? this.receptionistjsonb,
      salespersonjsonb: salespersonjsonb ?? this.salespersonjsonb,
      designjsonb: designjsonb ?? this.designjsonb,
      accountsjsonb: accountsjsonb ?? this.accountsjsonb,
      productionjsonb: productionjsonb ?? this.productionjsonb,
    );
  }
  static JobStatus _getJobStatus(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return JobStatus.received;
      case 'assigned_labour':
        return JobStatus.assignedLabour;
      case 'in_progress':
      case 'printing':
      case 'forwarded for printing':
      case 'processed_for_printing':
        return JobStatus.inProgress;
      case 'completed':
      case 'production_complete':
        return JobStatus.completed;
      case 'on_hold':
        return JobStatus.onHold;
      case 'printing_completed':
        return JobStatus.printingCompleted;
      case 'pending':
      default:
        return JobStatus.pending;
    }
  }

  static String _getActionForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Assign Workers';
      case 'in_progress':
        return 'Update Progress';
      case 'completed':
        return 'View Report';
      case 'on_hold':
        return 'Resolve Issue';
      default:
        return 'View Details';
    }
  }

  // Returns true if this job should be considered 'received' (ready for production)
  bool get isreceived {
    // Design must be completed
    final design = designjsonb;
    final production = productionjsonb;
    // Check if design is a Map and status is 'completed'
    final designCompleted = design != null &&
      ((design['status']?.toString().toLowerCase() == 'completed') ||
       (design['status']?.toString().toLowerCase() == 'design completed'));
    final productionIsNull = production == null || production.isEmpty || production['current_status'] == null;
    return designCompleted && productionIsNull;
  }

  // Always use the computed status for display
  JobStatus get computedStatus {
    switch (status) {
      case JobStatus.received:
        return JobStatus.received;
      case JobStatus.assignedLabour:
        return JobStatus.assignedLabour;
      case JobStatus.inProgress:
        return JobStatus.inProgress;
      case JobStatus.processedForPrinting:
        return JobStatus.processedForPrinting;
      case JobStatus.completed:
        return JobStatus.completed;
      case JobStatus.onHold:
        return JobStatus.onHold;
      case JobStatus.printingCompleted:
        return JobStatus.printingCompleted;
      default:
        // fallback for legacy or unknown
        return JobStatus.pending;
    }
  }
}
