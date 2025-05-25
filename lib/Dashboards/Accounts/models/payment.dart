enum PaymentMethod {
  creditCard,
  bankTransfer,
  cash,
  check,
  digitalWallet,
  other,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
  partiallyRefunded,
  cancelled,
}

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String? processedBy;
  final String? transactionId;
  final String? paymentGatewayResponse;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.status,
    required this.paymentDate,
    this.reference,
    this.notes,
    this.processedBy,
    this.transactionId,
    this.paymentGatewayResponse,
    this.createdAt,
    this.updatedAt,
  });

  // Convert a map to a Payment object
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      invoiceId: map['invoiceId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: _parsePaymentMethod(map['method'] ?? ''),
      status: _parsePaymentStatus(map['status'] ?? ''),
      paymentDate: DateTime.parse(map['paymentDate'] ?? DateTime.now().toIso8601String()),
      reference: map['reference'],
      notes: map['notes'],
      processedBy: map['processedBy'],
      transactionId: map['transactionId'],
      paymentGatewayResponse: map['paymentGatewayResponse'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Convert a Payment object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentDate': paymentDate.toIso8601String(),
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (processedBy != null) 'processedBy': processedBy,
      if (transactionId != null) 'transactionId': transactionId,
      if (paymentGatewayResponse != null) 'paymentGatewayResponse': paymentGatewayResponse,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy of the payment with updated fields
  Payment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? reference,
    String? notes,
    String? processedBy,
    String? transactionId,
    String? paymentGatewayResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      processedBy: processedBy ?? this.processedBy,
      transactionId: transactionId ?? this.transactionId,
      paymentGatewayResponse: paymentGatewayResponse ?? this.paymentGatewayResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to parse PaymentMethod from string
  static PaymentMethod _parsePaymentMethod(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.toString().split('.').last == method,
      orElse: () => PaymentMethod.other,
    );
  }

  // Helper method to parse PaymentStatus from string
  static PaymentStatus _parsePaymentStatus(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => PaymentStatus.pending,
    );
  }
}
