class EmployeePayment {
  final String jobNo;
  final String employee;
  final String date;
  final String amount;
  final String status;

  EmployeePayment({
    required this.jobNo,
    required this.employee,
    required this.date,
    required this.amount,
    required this.status,
  });

  // Convert a map to an EmployeePayment object
  factory EmployeePayment.fromMap(Map<String, dynamic> map) {
    return EmployeePayment(
      jobNo: map['jobNo'] ?? '',
      employee: map['employee'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }

  // Convert an EmployeePayment object to a map
  Map<String, dynamic> toMap() {
    return {
      'jobNo': jobNo,
      'employee': employee,
      'date': date,
      'amount': amount,
      'status': status,
    };
  }
}
