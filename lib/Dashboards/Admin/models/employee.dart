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
  });  factory Employee.fromJson(Map<String, dynamic> json) {
    // Debug print
    print('Employee.fromJson: Processing employee ${json['id']}');
    print('Employee.fromJson: Role from json: ${json['role']} (type: ${json['role']?.runtimeType})');
    
    // Handle role field which can be a String, List, or other type
    String role = '';
    final roleValue = json['role'];
    
    if (roleValue is String) {
      print('Employee.fromJson: Role is String: $roleValue');
      role = roleValue;
    } else if (roleValue is List) {
      print('Employee.fromJson: Role is List: $roleValue');
      if (roleValue.isNotEmpty) {
        role = roleValue.first.toString();
        print('Employee.fromJson: Using first element: $role');
      } else {
        print('Employee.fromJson: List is empty, using empty string');
      }
    } else if (roleValue != null) {
      print('Employee.fromJson: Role is ${roleValue.runtimeType}: $roleValue');
      // Convert any other type to string
      role = roleValue.toString();
    } else {
      print('Employee.fromJson: Role is null, using empty string');
    }
    
    try {      // Also handle assignedJob that might be list or other type
      String? assignedJob = null;
      final assignedJobValue = json['assigned_job'];
      if (assignedJobValue is String) {
        assignedJob = assignedJobValue;
      } else if (assignedJobValue is List) {
        assignedJob = assignedJobValue.isNotEmpty ? assignedJobValue.first.toString() : null;
      } else if (assignedJobValue != null) {
        assignedJob = assignedJobValue.toString();
      }
      
      print('Employee.fromJson: Branch ID type: ${json['branch_id']?.runtimeType}');
      
      return Employee(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        phone: json['phone'] as String,
        role: role,
        branchId: int.parse(json['branch_id'].toString()),  // Handle string or int
        createdAt: DateTime.parse(json['created_at'] as String),
        isAvailable: json['is_available'] == null ? null : json['is_available'] is bool 
            ? json['is_available'] as bool 
            : json['is_available'].toString().toLowerCase() == 'true',
        assignedJob: assignedJob,
      );
    } catch (e) {
      print('Employee.fromJson: Error creating Employee: $e');
      print('Employee.fromJson: Json data: $json');
      rethrow;
    }
  }
}
