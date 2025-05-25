// Model for a worker/labour in production
class Worker {
  final String name;
  final String role;
  final String image;
  final bool assigned;

  Worker({
    required this.name,
    required this.role,
    required this.image,
    this.assigned = false,
  });
}
