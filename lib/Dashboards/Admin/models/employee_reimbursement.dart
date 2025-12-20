import 'package:uuid/uuid.dart';

enum ReimbursementStatus { pending, approved, rejected, paid }

class EmployeeReimbursement {
  final String id;
  final String empId;
  final String empName;
  final double amount;
  final DateTime reimbursementDate;
  final String purpose;
  final String? receiptUrl;
  final String? remarks;
  final ReimbursementStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmployeeReimbursement({
    String? id,
    required this.empId,
    required this.empName,
    required this.amount,
    required this.reimbursementDate,
    required this.purpose,
    this.receiptUrl,
    this.remarks,
    this.status = ReimbursementStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EmployeeReimbursement.fromJson(Map<String, dynamic> json) {
    return EmployeeReimbursement(
      id: json['id'],
      empId: json['emp_id'],
      empName: json['emp_name'],
      amount: (json['amount'] as num).toDouble(),
      reimbursementDate: DateTime.parse(json['reimbursement_date']),
      purpose: json['purpose'],
      receiptUrl: json['receipt_url'],
      remarks: json['remarks'],
      status: _statusFromString(json['status']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'emp_id': empId,
        'emp_name': empName,
        'amount': amount,
        'reimbursement_date': reimbursementDate.toIso8601String(),
        'purpose': purpose,
        'receipt_url': receiptUrl,
        'remarks': remarks,
        'status': status.toString().split('.').last,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static ReimbursementStatus _statusFromString(String? status) {
    switch (status) {
      case 'approved':
        return ReimbursementStatus.approved;
      case 'rejected':
        return ReimbursementStatus.rejected;
      case 'paid':
        return ReimbursementStatus.paid;
      case 'pending':
      default:
        return ReimbursementStatus.pending;
    }
  }

  String get statusString => status.toString().split('.').last;

  EmployeeReimbursement copyWith({
    String? id,
    String? empId,
    String? empName,
    double? amount,
    DateTime? reimbursementDate,
    String? purpose,
    String? receiptUrl,
    String? remarks,
    ReimbursementStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeReimbursement(
      id: id ?? this.id,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      amount: amount ?? this.amount,
      reimbursementDate: reimbursementDate ?? this.reimbursementDate,
      purpose: purpose ?? this.purpose,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
