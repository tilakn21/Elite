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

  factory AdminJob.fromJson(Map<String, dynamic> json) {
    return AdminJob(
      no: json['no'] as String,
      title: json['title'] as String,
      client: json['client'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'title': title,
      'client': client,
      'date': date,
      'status': status,
    };
  }
}
