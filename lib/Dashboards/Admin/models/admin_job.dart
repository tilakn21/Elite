enum JobStatus {
  pending,
  inProcess,
  completed,
}

class AdminJob {
  final String jobNo;
  final String title;
  final String clientName;
  final DateTime date;
  final String status;

  const AdminJob({
    required this.jobNo,
    required this.title,
    required this.clientName,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'no': jobNo,
    'title': title,
    'client': clientName,
    'date': date.toString(),
    'status': status,
  };

  factory AdminJob.fromJson(Map<String, dynamic> json) => AdminJob(
    jobNo: json['no'] as String,
    title: json['title'] as String,
    clientName: json['client'] as String,
    date: DateTime.parse(json['date'] as String),
    status: json['status'] as String,
  );
}
