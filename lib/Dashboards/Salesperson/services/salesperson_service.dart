import 'package:supabase_flutter/supabase_flutter.dart';

class SalespersonService {
  Future<String?> fetchSalespersonNameById(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('employee')
          .select('full_name')
          .eq('id', userId)
          .single();
      return response != null ? response['full_name'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchSalespersonProfileById(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('employee')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Sets is_available to true for the given salesperson in jobs_employee table
  /// Always decrements number_of_jobs by 1 if number_of_jobs > 0
  Future<bool> setSalespersonAvailable(String salespersonId) async {
    try {
      final supabase = Supabase.instance.client;
      print('[setSalespersonAvailable] Called with salespersonId: $salespersonId');
      // Fetch current number_of_jobs
      final employee = await supabase
          .from('employee')
          .select('number_of_jobs')
          .eq('id', salespersonId)
          .single();
      print('[setSalespersonAvailable] Employee fetch result: $employee');
      int numberOfJobs = (employee['number_of_jobs'] ?? 0) as int;
      print('[setSalespersonAvailable] Before update: number_of_jobs = $numberOfJobs');
      if (numberOfJobs > 0) {
        numberOfJobs -= 1;
      }
      await supabase
          .from('employee')
          .update({'is_available': true, 'number_of_jobs': numberOfJobs})
          .eq('id', salespersonId);
      print('[setSalespersonAvailable] After update: number_of_jobs = $numberOfJobs');
      return true;
    } catch (e) {
      print('[setSalespersonAvailable] ERROR: $e');
      return false;
    }
  }

  // Helper: Use this to call setSalespersonAvailable with the userId from fetchSalespersonProfileById
  Future<bool> setCurrentSalespersonAvailable(String userId) async {
    return await setSalespersonAvailable(userId);
  }
}
