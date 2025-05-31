// Model for an Employee (Admin dashboard)
class Employee {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final int branchId;
  final DateTime createdAt;
  final bool? isAvailable;
  final String? assignedJob;

  Employee({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.branchId,
    required this.createdAt,
    this.isAvailable,
    this.assignedJob,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      branchId: json['branch_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAvailable: json['is_available'] == null ? null : json['is_available'] as bool,
      assignedJob: json['assigned_job'] as String?,
    );
  }
}
