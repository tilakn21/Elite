import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_reimbursement.dart';

class ReimbursementService {
  final _client = Supabase.instance.client;

  Future<List<EmployeeReimbursement>> fetchReimbursements() async {
    try {
      final response = await _client
          .from('employee_reimbursement')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => EmployeeReimbursement.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reimbursements: $e');
    }
  }

  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? remarks}) async {
    print('[ReimbursementService] updateReimbursementStatus called with id: $id, status: $status, remarks: $remarks');
    try {
      final updateMap = {
        'status': status.toString().split('.').last,
        if (remarks != null) 'remarks': remarks,
      };
      print('[ReimbursementService] Update map: ' + updateMap.toString());
      final response = await _client
          .from('employee_reimbursement')
          .update(updateMap)
          .eq('id', id);
      print('[ReimbursementService] Supabase update response: ' + response.toString());
    } catch (e) {
      print('[ReimbursementService] ERROR: $e');
      throw Exception('Failed to update reimbursement status: $e');
    }
  }

  Future<void> approveReimbursement(String id, {String? remarks}) async {
    print('[ReimbursementService] approveReimbursement called for id: $id');
    await updateReimbursementStatus(id, ReimbursementStatus.approved, remarks: remarks);
  }

  Future<void> declineReimbursement(String id, {String? remarks}) async {
    print('[ReimbursementService] declineReimbursement called for id: $id');
    await updateReimbursementStatus(id, ReimbursementStatus.rejected, remarks: remarks);
  }
}
