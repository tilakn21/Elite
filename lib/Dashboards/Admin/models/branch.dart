class Branch {
  final String name;
  final int completedJobs;
  final double revenue;
  final int delays;

  const Branch({
    required this.name,
    required this.completedJobs,
    required this.revenue,
    required this.delays,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'completed': completedJobs,
    'revenue': revenue,
    'delays': delays,
  };

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    name: json['name'] as String,
    completedJobs: json['completed'] as int,
    revenue: (json['revenue'] as String).replaceAll('\u0000', '£').replaceAll(',', '').substring(1),
    delays: json['delays'] as int,
  );
}
