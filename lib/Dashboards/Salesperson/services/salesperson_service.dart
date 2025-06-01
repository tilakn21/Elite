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
}
