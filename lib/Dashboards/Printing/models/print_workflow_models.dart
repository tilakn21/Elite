class PrintAttempt {
  final int attemptNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // completed|failed|cancelled
  final int? durationMinutes;
  final String? notes;

  PrintAttempt({
    required this.attemptNumber,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.durationMinutes,
    this.notes,
  });

  factory PrintAttempt.fromJson(Map<String, dynamic> json) {
    return PrintAttempt(
      attemptNumber: json['attempt_number'] ?? 0,
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
      status: json['status'] ?? 'pending',
      durationMinutes: json['duration_minutes'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_number': attemptNumber,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status,
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }
}

class QualityCheck {
  final String checkId;
  final DateTime checkedAt;
  final int rating; // 1-5
  final String status; // approved|rejected
  final Map<String, bool> checklist;
  final List<String> issues;
  final String? feedback;

  QualityCheck({
    required this.checkId,
    required this.checkedAt,
    required this.rating,
    required this.status,
    required this.checklist,
    required this.issues,
    this.feedback,
  });

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      checkId: json['check_id'] ?? '',
      checkedAt: DateTime.parse(json['checked_at']),
      rating: json['rating'] ?? 0,
      status: json['status'] ?? 'approved',
      checklist: Map<String, bool>.from(json['checklist'] ?? {}),
      issues: List<String>.from(json['issues'] ?? []),
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_id': checkId,
      'checked_at': checkedAt.toIso8601String(),
      'rating': rating,
      'status': status,
      'checklist': checklist,
      'issues': issues,
      'feedback': feedback,
    };
  }
}

class ReprintRequest {
  final String requestId;
  final DateTime requestedAt;
  final String reason; // quality_issues|client_changes|material_defect
  final String description;

  ReprintRequest({
    required this.requestId,
    required this.requestedAt,
    required this.reason,
    required this.description,
  });

  factory ReprintRequest.fromJson(Map<String, dynamic> json) {
    return ReprintRequest(
      requestId: json['request_id'] ?? '',
      requestedAt: DateTime.parse(json['requested_at']),
      reason: json['reason'] ?? 'quality_issues',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'requested_at': requestedAt.toIso8601String(),
      'reason': reason,
      'description': description,
    };
  }
}
