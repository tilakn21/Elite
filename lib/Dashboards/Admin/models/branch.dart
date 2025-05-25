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
}
