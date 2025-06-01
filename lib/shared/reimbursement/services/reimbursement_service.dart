import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reimbursement_model.dart';
import 'package:flutter/foundation.dart';

class ReimbursementService {
  /// Add a new reimbursement request to Supabase
  Future<void> addReimbursementRequest(EmployeeReimbursement reimbursement, {File? receiptImage}) async {
    String? receiptUrl = reimbursement.receiptUrl;
    try {
      if (receiptImage != null) {
        debugPrint('[ReimbursementService] Uploading image to Supabase Storage');
        final fileName = 'receipts/${DateTime.now().millisecondsSinceEpoch}_${reimbursement.empId}.jpg';
        final uploadPath = await Supabase.instance.client.storage
            .from('eliteimage')
            .upload(fileName, receiptImage);
            
        if (uploadPath.isEmpty) {
          throw Exception('Failed to upload receipt image.');
        }
        
        receiptUrl = Supabase.instance.client.storage
            .from('eliteimage')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client
          .from('employee_reimbursement')
          .insert({
        'emp_id': reimbursement.empId,
        'emp_name': reimbursement.empName,
        'amount': reimbursement.amount,
        'reimbursement_date': reimbursement.reimbursementDate.toIso8601String(),
        'purpose': reimbursement.purpose,
        'receipt_url': receiptUrl,
        'status': reimbursement.status.toString().split('.').last,
        'remarks': reimbursement.remarks,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();
    } catch (e, stack) {
      debugPrint('[ReimbursementService] ERROR: $e\n$stack');
      throw Exception('Failed to add reimbursement request: $e');
    }
  }

  /// Update reimbursement status (admin only)
  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? adminRemarks}) async {
    try {
      await Supabase.instance.client
        .from('employee_reimbursement')
        .update({
          'status': status.toString().split('.').last,
          'remarks': adminRemarks,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update reimbursement status: $e');
    }
  }

  /// Fetch all reimbursements
  Future<List<EmployeeReimbursement>> fetchReimbursements() async {
    try {
      final response = await Supabase.instance.client
        .from('employee_reimbursement')
        .select()
        .order('created_at', ascending: false);
      
      return (response as List)
        .map((item) => EmployeeReimbursement.fromJson(item))
        .toList();
    } catch (e) {
      throw Exception('Failed to fetch reimbursement requests: $e');
    }
  }

  /// Fetch reimbursements for a specific employee
  Future<List<EmployeeReimbursement>> fetchReimbursementsByEmployee(String empId) async {
    try {
      final response = await Supabase.instance.client
        .from('employee_reimbursement')
        .select()
        .eq('emp_id', empId)
        .order('created_at', ascending: false);
      
      return (response as List)
        .map((item) => EmployeeReimbursement.fromJson(item))
        .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee reimbursements: $e');
    }
  }
}
