import 'printing_specification.dart';

enum PrintingStatus { queued, inProgress, completed, failed, onHold }

class PrintingJob {
  final String id;
  final String jobNo;
  final String title;
  final String clientName;
  final DateTime submittedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final PrintingStatus status;
  final List<PrintingSpecification> specifications;
  final String assignedPrinter;
  final int copies;
  final String? notes;
  final double progress;
  final List<String>? issues;

  const PrintingJob({
    required this.id,
    required this.jobNo,
    required this.title,
    required this.clientName,
    required this.submittedAt,
    required this.status,
    required this.specifications,
    required this.assignedPrinter,
    required this.copies,
    required this.progress,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.issues,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobNo': jobNo,
        'title': title,
        'clientName': clientName,
        'submittedAt': submittedAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'specifications': specifications.map((s) => s.toJson()).toList(),
        'assignedPrinter': assignedPrinter,
        'copies': copies,
        'notes': notes,
        'progress': progress,
        'issues': issues,
      };

  factory PrintingJob.fromJson(Map<String, dynamic> json) => PrintingJob(
        id: json['id'] as String,
        jobNo: json['jobNo'] as String,
        title: json['title'] as String,
        clientName: json['clientName'] as String,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
        startedAt: json['startedAt'] == null
            ? null
            : DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        status: PrintingStatus.values.firstWhere(
            (e) => e.name == json['status'] as String,
            orElse: () => PrintingStatus.queued),
        specifications: (json['specifications'] as List)
            .map((spec) =>
                PrintingSpecification.fromJson(spec as Map<String, dynamic>))
            .toList(),
        assignedPrinter: json['assignedPrinter'] as String,
        copies: json['copies'] as int,
        notes: json['notes'] as String?,
        progress: (json['progress'] as num).toDouble(),
        issues: (json['issues'] as List?)?.cast<String>(),
      );
}
