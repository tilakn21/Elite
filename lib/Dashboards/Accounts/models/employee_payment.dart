import 'package:flutter/material.dart';

enum PaymentStatus {
  paid,
  pending,
  rejected,
  approved
}

class EmployeePayment {
  final String id;
  final String empId;
  final String empName;
  final double amount;
  final DateTime reimbursementDate;
  final String purpose;
  final String? receiptUrl;
  final PaymentStatus status;
  final String? remarks;
  final DateTime? createdAt;

  EmployeePayment({
    required this.id,
    required this.empId,
    required this.empName,
    required this.amount,
    required this.reimbursementDate,
    required this.purpose,
    this.receiptUrl,
    required this.status,
    this.remarks,
    this.createdAt,
  });

  factory EmployeePayment.fromJson(Map<String, dynamic> json) {
    String statusStr = (json['status'] ?? 'pending').toString().toLowerCase();
    PaymentStatus status;
    switch (statusStr) {
      case 'paid':
        status = PaymentStatus.paid;
        break;
      case 'rejected':
        status = PaymentStatus.rejected;
        break;
      case 'approved':
        status = PaymentStatus.approved;
        break;
      default:
        status = PaymentStatus.pending;
    }

    return EmployeePayment(
      id: json['id'].toString(),
      empId: json['emp_id'].toString(),
      empName: json['emp_name'].toString(),
      amount: (json['amount'] as num).toDouble(),
      reimbursementDate: DateTime.parse(json['reimbursement_date']),
      purpose: json['purpose'].toString(),
      receiptUrl: json['receipt_url']?.toString(),
      status: status,
      remarks: json['remarks']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emp_id': empId,
      'emp_name': empName,
      'amount': amount,
      'reimbursement_date': reimbursementDate.toIso8601String(),
      'purpose': purpose,
      'receipt_url': receiptUrl,
      'status': status.name,
      'remarks': remarks,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
