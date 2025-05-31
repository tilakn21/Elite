// Model for an invoice in Accounts dashboard

// Enum for invoice status
enum InvoiceStatus {
  draft,
  sent,
  pending,
  paid,
  overdue,
  partial,
  cancelled
}

// Model for invoice item
class InvoiceItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
  });

  double get total => quantity * unitPrice;

  // Factory constructor for creating a new InvoiceItem instance from a map.
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
    );
  }

  // Method for converting an InvoiceItem instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
    };
  }
}

// Model for invoice
class Invoice {
  final String id;
  final String invoiceNo;
  final String clientId;
  final String clientName;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final double balanceDue;
  final InvoiceStatus status;
  final DateTime? paidDate;
  final String? paymentMethod;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.clientId,
    required this.clientName,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    this.paidDate,
    this.paymentMethod,
    required this.items,
  });

  // Factory constructor for creating a new Invoice instance from a map.
  factory Invoice.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List<dynamic>?;
    List<InvoiceItem> itemList = itemsFromJson != null
        ? itemsFromJson.map((i) => InvoiceItem.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return Invoice(
      id: json['id'] as String,
      invoiceNo: json['invoiceNo'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
      status: InvoiceStatus.values.byName(json['status'] as String? ?? InvoiceStatus.draft.name),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      paymentMethod: json['paymentMethod'] as String?,
      items: itemList,
    );
  }

  // Method for converting an Invoice instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'clientId': clientId,
      'clientName': clientName,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'balanceDue': balanceDue,
      'status': status.name, // Uses the enum value's name string
      'paidDate': paidDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Factory method to create a new invoice with default values
  static Invoice createNew({
    required String clientId,
    required String clientName,
    required DateTime issueDate,
    required DateTime dueDate,
  }) {
    return Invoice(
      id: '',
      invoiceNo: '',
      clientId: clientId,
      clientName: clientName,
      issueDate: issueDate,
      dueDate: dueDate,
      subtotal: 0.0,
      taxAmount: 0.0,
      discountAmount: 0.0,
      totalAmount: 0.0,
      amountPaid: 0.0,
      balanceDue: 0.0,
      status: InvoiceStatus.draft,
      items: [],
    );
  }

  // Method to create a copy of this invoice with some fields replaced
  Invoice copyWith({
    String? id,
    String? invoiceNo,
    String? clientId,
    String? clientName,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? amountPaid,
    double? balanceDue,
    InvoiceStatus? status,
    DateTime? paidDate,
    String? paymentMethod,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }
}
