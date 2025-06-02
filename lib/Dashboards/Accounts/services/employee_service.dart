import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_payment.dart';

class EmployeeService {
  final _supabase = Supabase.instance.client;

  Future<List<EmployeePayment>> getEmployeePayments() async {
    try {
      final response = await _supabase
          .from('employee_reimbursement')
          .select()
          .inFilter('status', ['pending', 'paid', 'rejected', 'approved'])
          .order('reimbursement_date', ascending: false);

      print('Fetched reimbursements: $response'); // Debug print

      return response.map<EmployeePayment>((payment) {
        return EmployeePayment.fromJson(payment);
      }).toList();
    } catch (e) {
      print('Error fetching reimbursements: $e'); // Debug print
      rethrow;
    }
  }

  Future<void> updateEmployeePayment(String id, EmployeePayment payment) async {
    await _supabase
        .from('employee_reimbursement')
        .update({
          'status': payment.status.name,
          'remarks': payment.remarks,
        })
        .eq('id', id);
  }
}
