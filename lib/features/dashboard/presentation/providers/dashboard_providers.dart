import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_model.dart';
import '../../../../models/user_role.dart';

// User Provider
final currentUserProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: '1',
    email: 'admin@elitesigns.com',
    fullName: 'John Doe',
    role: UserRole.admin,
    isActive: true,
  );
});

// Dashboard State Provider
final dashboardIndexProvider = StateProvider<int>((ref) => 0);

// Jobs Provider
final jobsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'JOB-001',
      'client': 'ABC Corporation',
      'type': 'Signage Installation',
      'status': 'In Progress',
      'progress': 0.6,
      'dueDate': 'Mar 20, 2024',
    },
    {
      'id': 'JOB-002',
      'client': 'XYZ Industries',
      'type': 'Vehicle Wrap',
      'status': 'Pending Review',
      'progress': 0.8,
      'dueDate': 'Mar 18, 2024',
    },
    {
      'id': 'JOB-003',
      'client': '123 Company',
      'type': 'Banner Design',
      'status': 'In Progress',
      'progress': 0.3,
      'dueDate': 'Mar 22, 2024',
    },
  ];
});

// Appointments Provider
final appointmentsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'time': '09:00 AM',
      'client': 'ABC Corporation',
      'purpose': 'Initial Consultation',
      'status': 'Confirmed',
    },
    {
      'time': '11:30 AM',
      'client': 'XYZ Industries',
      'purpose': 'Design Review',
      'status': 'Pending',
    },
    {
      'time': '02:00 PM',
      'client': '123 Company',
      'purpose': 'Site Visit',
      'status': 'Confirmed',
    },
  ];
});

// Activity Provider
final activitiesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'title': 'New order received', 'time': '2 hours ago'},
    {'title': 'Design approved', 'time': '4 hours ago'},
    {'title': 'Production started', 'time': '6 hours ago'},
    {'title': 'Delivery scheduled', 'time': '1 day ago'},
  ];
});
