// Model for an Admin job (for job tables, etc.)
class AdminJob {
  final String no;
  final String title;
  final String client;
  final String date;
  final String status;

  AdminJob({
    required this.no,
    required this.title,
    required this.client,
    required this.date,
    required this.status,
  });
}
