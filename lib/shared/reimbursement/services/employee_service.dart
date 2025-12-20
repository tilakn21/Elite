import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeService {
  /// Fetch employee name by id from employee table
  Future<String?> fetchEmployeeName(String empId) async {
    final supabase = Supabase.instance.client;
    final result = await supabase
        .from('employee')
        .select('full_name')
        .eq('id', empId)
        .maybeSingle();
    return result != null ? result['full_name'] as String? : null;
  }
}
