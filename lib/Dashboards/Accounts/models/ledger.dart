class LedgerEntry {
  final String id;
  final DateTime date;
  final String accountId;
  final String description;
  final double debit;
  final double credit;
  final String? reference;
  final String? transactionId;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.accountId,
    required this.description,
    required this.debit,
    required this.credit,
    this.reference,
    this.transactionId,
  });

  // Convert a map to a LedgerEntry object
  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      accountId: map['accountId'] ?? '',
      description: map['description'] ?? '',
      debit: (map['debit'] ?? 0.0).toDouble(),
      credit: (map['credit'] ?? 0.0).toDouble(),
      reference: map['reference'],
      transactionId: map['transactionId'],
    );
  }

  // Convert a LedgerEntry object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'accountId': accountId,
      'description': description,
      'debit': debit,
      'credit': credit,
      if (reference != null) 'reference': reference,
      if (transactionId != null) 'transactionId': transactionId,
    };
  }

  // Get the balance (debit - credit)
  double get balance => debit - credit;
}
