import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../models/user_role.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  // Auth Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.toString().split('.').last,
      },
    );

    if (response.user != null) {
      await _createUserProfile(response.user!.id, fullName, role);
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // User Profile Methods
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response =
        await _supabase.from('profiles').select().eq('id', user.id).single();

    return UserModel.fromJson(response);
  }

  Future<void> _createUserProfile(
    String userId,
    String fullName,
    UserRole role,
  ) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'role': role.toString().split('.').last,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Database Methods
  Future<List<Map<String, dynamic>>> getJobs() async {
    return await _supabase.from('jobs').select();
  }

  Future<List<Map<String, dynamic>>> getAppointments() async {
    return await _supabase.from('appointments').select();
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    return await _supabase.from('profiles').select();
  }

  // Real-time Subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToJobs() {
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id']).order('created_at');
  }

  Stream<List<Map<String, dynamic>>> subscribeToAppointments() {
    return _supabase
        .from('appointments')
        .stream(primaryKey: ['id']).order('created_at');
  }
}
