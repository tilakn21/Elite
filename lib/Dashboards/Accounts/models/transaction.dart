enum TransactionType {
  income,
  expense,
  transfer,
  payment,
  refund,
}

class Transaction {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final DateTime date;
  final String? reference;
  final String? category;
  final String? accountId;
  final String? relatedTransactionId;

  Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    this.reference,
    this.category,
    this.accountId,
    this.relatedTransactionId,
  });

  // Convert a map to a Transaction object
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      type: _parseTransactionType(map['type'] ?? ''),
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      reference: map['reference'],
      category: map['category'],
      accountId: map['accountId'],
      relatedTransactionId: map['relatedTransactionId'],
    );
  }

  // Convert a Transaction object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      if (reference != null) 'reference': reference,
      if (category != null) 'category': category,
      if (accountId != null) 'accountId': accountId,
      if (relatedTransactionId != null) 'relatedTransactionId': relatedTransactionId,
    };
  }

  // Helper method to parse TransactionType from string
  static TransactionType _parseTransactionType(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => TransactionType.payment,
    );
  }
}
