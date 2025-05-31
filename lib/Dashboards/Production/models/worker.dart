// Model for a production worker based on employee table
class Worker {
  final String id;
  final String name;
  final String phone;
  final String role;
  final int? branchId;
  final String image;
  final bool isAvailable;
  final bool assigned;
  final String? assignedJob;
  
  Worker({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.branchId,
    String? image,
    required this.isAvailable,
    this.assigned = false,
    this.assignedJob,
  }) : image = image ?? 'assets/images/avatars/default_avatar.png';
  factory Worker.fromJson(Map<String, dynamic> json) {
    // First check if the worker has an assigned job
    String? assignedJob = json['assigned_job']?.toString();
    
    // Then check availability - a worker is available only if they don't have an assigned job
    // and their is_available flag is true
    bool isAvailable = false;
    if (json['is_available'] is bool) {
      isAvailable = json['is_available'];
    } else if (json['is_available']?.toString().toLowerCase() == 'true') {
      isAvailable = true;
    }
    
    // A worker is assigned if they have an assigned job
    bool assigned = assignedJob != null && assignedJob.isNotEmpty;

    // Use local asset for avatar instead of network image
    return Worker(
      id: json['id'].toString(),
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'prod_labour',
      branchId: json['branch_id'] != null ? int.tryParse(json['branch_id'].toString()) : null,
      image: 'assets/images/avatars/default_avatar.png',
      isAvailable: isAvailable && !assigned, // Available only if marked available AND not assigned
      assigned: assigned,
      assignedJob: assignedJob,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': name,
      'phone': phone,  
      'role': role,
      'branch_id': branchId,
      'image': image,
      'is_available': isAvailable,
      'assigned_job': assignedJob,
    };
  }

  Worker copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    int? branchId,
    String? image,
    bool? isAvailable,
    bool? assigned,
    String? assignedJob,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      assigned: assigned ?? this.assigned,
      assignedJob: assignedJob ?? this.assignedJob,
    );
  }
}
