// Model for an Admin job (for job tables, etc.)
class AdminJob {
  final String no;
  final String title;
  final String client;
  final String date;
  final String status;
  final Map<String, dynamic>? receptionist;
  final Map<String, dynamic>? salesperson;
  final Map<String, dynamic>? design;
  final Map<String, dynamic>? accountant;
  final Map<String, dynamic>? production;
  final Map<String, dynamic>? printing;

  AdminJob({
    required this.no,
    required this.title,
    required this.client,
    required this.date,
    required this.status,
    this.receptionist,
    this.salesperson,
    this.design,
    this.accountant,
    this.production,
    this.printing,
  });

  factory AdminJob.fromJson(Map<String, dynamic> json) {
    return AdminJob(
      no: json['no'] as String,
      title: json['title'] as String,
      client: json['client'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      receptionist: json['receptionist'] as Map<String, dynamic>?,
      salesperson: json['salesperson'] as Map<String, dynamic>?,
      design: json['design'] as Map<String, dynamic>?,
      accountant: json['accountant'] as Map<String, dynamic>?,
      production: json['production'] as Map<String, dynamic>?,
      printing: json['printing'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'title': title,
      'client': client,
      'date': date,
      'status': status,
      'receptionist': receptionist,
      'salesperson': salesperson,
      'design': design,
      'accountant': accountant,
      'production': production,
      'printing': printing,
    };
  }
}
