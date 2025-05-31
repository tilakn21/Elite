// Model for an Admin branch (for branch stats, etc.)
class Branch {
  final String name;
  final int completed;
  final String revenue;
  final int delays;

  Branch({
    required this.name,
    required this.completed,
    required this.revenue,
    required this.delays,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'] as String,
      completed: json['completed'] as int,
      revenue: json['revenue'] as String, // Assuming revenue is stored as a string, adjust if it's a number
      delays: json['delays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'completed': completed,
      'revenue': revenue,
      'delays': delays,
    };
  }
}
