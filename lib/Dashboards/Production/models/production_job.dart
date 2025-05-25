// Model for a production job (for job list, job table, job status, etc.)
class ProductionJob {
  final String jobNo;
  final String clientName;
  final String dueDate;
  final String description;
  final JobStatus status;
  final String action;

  ProductionJob({
    required this.jobNo,
    required this.clientName,
    required this.dueDate,
    required this.description,
    required this.status,
    required this.action,
  });
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
