// Model for a worker/labour in production
class Worker {
  final String id;
  final String name;
  final String role;
  final String image;
  final bool assigned;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    this.assigned = false,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      image: json['image'] as String,
      assigned: json['assigned'] as bool? ?? false, // Default to false if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'image': image,
      'assigned': assigned,
    };
  }

  Worker copyWith({
    String? id,
    String? name,
    String? role,
    String? image,
    bool? assigned,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      image: image ?? this.image,
      assigned: assigned ?? this.assigned,
    );
  }
}
