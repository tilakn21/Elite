import 'package:supabase_flutter/supabase_flutter.dart';

class AccountsService {
  /// Fetch accountant's name, role, and branch_id from employee table
  Future<Map<String, dynamic>?> fetchAccountantDetails({String? accountantId}) async {
    final supabase = Supabase.instance.client;
    // Use demo id if not provided
    final String id = accountantId ?? '';
    if (id.isEmpty) return null;
    final result = await supabase
        .from('employee')
        .select('full_name, role, branch_id')
        .eq('id', id)
        .maybeSingle();
    return result;
  }

  /// Fetch branch name from branches table using branch_id
  Future<String?> fetchBranchName(int branchId) async {
    final supabase = Supabase.instance.client;
    final result = await supabase
        .from('branches')
        .select('name')
        .eq('id', branchId)
        .maybeSingle();
    return result != null ? result['name'] as String? : null;
  }
}
