class Job {
  final String jobNo;
  final String client;
  final String date;
  final String amount;
  final String status;

  Job({
    required this.jobNo,
    required this.client,
    required this.date,
    required this.amount,
    required this.status,
  });

  // Convert a map to a Job object
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      jobNo: map['jobNo'] ?? '',
      client: map['client'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }

  // Convert a Job object to a map
  Map<String, dynamic> toMap() {
    return {
      'jobNo': jobNo,
      'client': client,
      'date': date,
      'amount': amount,
      'status': status,
    };
  }
}
