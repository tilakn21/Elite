// Copied from Receptionist/services/reimbursement_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_reimbursement.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ReimbursementService {
  final Uuid _uuid = const Uuid();
  final List<EmployeeReimbursement> _mockReimbursements = [
    EmployeeReimbursement(
      id: 'rb1',
      empId: 'emp001',
      empName: 'John Smith',
      amount: 125.50,
      reimbursementDate: DateTime.now().subtract(const Duration(days: 5)),
      purpose: 'Office supplies and printing',
      remarks: 'Purchased stationery for client presentations',
      status: ReimbursementStatus.pending,
    ),
    EmployeeReimbursement(
      id: 'rb2',
      empId: 'emp002',
      empName: 'Sarah Johnson',
      amount: 89.75,
      reimbursementDate: DateTime.now().subtract(const Duration(days: 12)),
      purpose: 'Travel expenses',
      remarks: 'Client meeting transportation costs',
      status: ReimbursementStatus.approved,
    ),
    EmployeeReimbursement(
      id: 'rb3',
      empId: 'emp003',
      empName: 'Mike Brown',
      amount: 45.00,
      reimbursementDate: DateTime.now().subtract(const Duration(days: 8)),
      purpose: 'Equipment purchase',
      remarks: 'USB cable and adapters for site visits',
      status: ReimbursementStatus.rejected,
    ),
  ];

  Future<List<EmployeeReimbursement>> fetchReimbursementsFromSupabase() async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      // TODO: Implement actual Supabase query when backend is ready
      /*
      final response = await Supabase.instance.client
        .from('employee_reimbursement')
        .select()
        .order('created_at', ascending: false);
      return (response as List)
        .map((item) => EmployeeReimbursement.fromJson(item))
        .toList();
      */
      return List.from(_mockReimbursements);
    } catch (e) {
      throw Exception('Failed to fetch reimbursement requests: $e');
    }
  }

  Future<void> addReimbursementRequest(EmployeeReimbursement reimbursement, {File? receiptImage}) async {
    String? receiptUrl = reimbursement.receiptUrl;
    try {
      if (receiptImage != null) {
        debugPrint('[ReimbursementService] Uploading image to Supabase Storage (triggered by submit button)');
        final fileName = 'receipts/${DateTime.now().millisecondsSinceEpoch}_${reimbursement.empId}.jpg';
        debugPrint('[ReimbursementService] Uploading image: bucket=eliteimage, fileName=$fileName');
        final uploadPath = await Supabase.instance.client.storage
            .from('eliteimage')
            .upload(fileName, receiptImage);
        debugPrint('[ReimbursementService] Upload result: $uploadPath');
        if (uploadPath.isEmpty) {
          throw Exception('Failed to upload receipt image.');
        }
        final publicUrl = Supabase.instance.client.storage
            .from('eliteimage')
            .getPublicUrl(fileName);
        debugPrint('[ReimbursementService] Public URL: $publicUrl');
        receiptUrl = publicUrl;
      }
      debugPrint('[ReimbursementService] Inserting reimbursement into Supabase: empId=${reimbursement.empId}, empName=${reimbursement.empName}, amount=${reimbursement.amount}, date=${reimbursement.reimbursementDate}, purpose=${reimbursement.purpose}, receiptUrl=$receiptUrl');
      final response = await Supabase.instance.client
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
      debugPrint('[ReimbursementService] Insert response: $response');
    } catch (e, stack) {
      debugPrint('[ReimbursementService] ERROR: $e\n$stack');
      throw Exception('Failed to add reimbursement request: $e');
    }
  }

  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? adminRemarks}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      // TODO: Implement actual Supabase update when backend is ready
      /*
      await Supabase.instance.client
        .from('employee_reimbursement')
        .update({
          'status': status.toString().split('.').last,
          'remarks': adminRemarks,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
      */
      final index = _mockReimbursements.indexWhere((r) => r.id == id);
      if (index != -1) {
        _mockReimbursements[index] = _mockReimbursements[index].copyWith(
          status: status,
          remarks: adminRemarks ?? _mockReimbursements[index].remarks,
        );
      }
    } catch (e) {
      throw Exception('Failed to update reimbursement status: $e');
    }
  }

  Future<String?> uploadReceiptImage(File imageFile, String reimbursementId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      return 'https://example.com/receipts/$reimbursementId.jpg';
    } catch (e) {
      throw Exception('Failed to upload receipt image: $e');
    }
  }

  Future<List<EmployeeReimbursement>> fetchReimbursementsByEmployee(String empId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockReimbursements.where((r) => r.empId == empId).toList();
    } catch (e) {
      throw Exception('Failed to fetch employee reimbursements: $e');
    }
  }
}
