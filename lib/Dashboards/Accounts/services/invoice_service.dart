// Service for handling API communication related to Invoices
// import 'package:http/http.dart' as http; // Placeholder for HTTP requests - uncomment when ready
import '../models/invoice.dart';

class InvoiceService {

  // Fetch all invoices
  Future<List<Invoice>> getInvoices() async {
    // final response = await http.get(Uri.parse(_baseUrl));
    // if (response.statusCode == 200) {
    //   List<dynamic> body = jsonDecode(response.body);
    //   List<Invoice> invoices = body.map((dynamic item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
    //   return invoices;
    // } else {
    //   throw Exception('Failed to load invoices');
    // }
    print('InvoiceService: Fetching all invoices (mocked)');
    // Return a mock list for now
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      Invoice.createNew(clientId: 'client-001', clientName: 'Mock Client 1', issueDate: DateTime.now(), dueDate: DateTime.now().add(const Duration(days: 30)))
        .copyWith(id: 'inv-001', invoiceNo: 'INV-2024-001', totalAmount: 1500.0, status: InvoiceStatus.sent, items: [
          InvoiceItem(id: 'item-1', description: 'Service A', quantity: 1, unitPrice: 1000, taxRate: 0.1),
          InvoiceItem(id: 'item-2', description: 'Service B', quantity: 2, unitPrice: 200, taxRate: 0.1),
        ]),
      Invoice.createNew(clientId: 'client-002', clientName: 'Mock Client 2', issueDate: DateTime.now().subtract(const Duration(days: 10)), dueDate: DateTime.now().add(const Duration(days: 20)))
        .copyWith(id: 'inv-002', invoiceNo: 'INV-2024-002', totalAmount: 250.75, status: InvoiceStatus.paid, paidDate: DateTime.now(), items: [
          InvoiceItem(id: 'item-3', description: 'Product X', quantity: 5, unitPrice: 45, taxRate: 0.05),
        ]),
    ];
  }

  // Fetch a single invoice by ID
  Future<Invoice> getInvoiceById(String id) async {
    // final response = await http.get(Uri.parse('$_baseUrl/$id'));
    // if (response.statusCode == 200) {
    //   return Invoice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    // } else {
    //   throw Exception('Failed to load invoice $id');
    // }
    print('InvoiceService: Fetching invoice by ID: $id (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    return Invoice.createNew(clientId: 'client-003', clientName: 'Mock Client Detail', issueDate: DateTime.now(), dueDate: DateTime.now().add(const Duration(days: 15)))
        .copyWith(id: id, invoiceNo: 'INV-DETAIL-001', totalAmount: 500.0, status: InvoiceStatus.pending, items: [
          InvoiceItem(id: 'item-4', description: 'Consulting Hours', quantity: 10, unitPrice: 45, taxRate: 0.0)
        ]);
  }

  // Create a new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    // final response = await http.post(
    //   Uri.parse(_baseUrl),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(invoice.toJson()),
    // );
    // if (response.statusCode == 201) { // 201 Created
    //   return Invoice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    // } else {
    //   throw Exception('Failed to create invoice. Status: ${response.statusCode}, Body: ${response.body}');
    // }
    print('InvoiceService: Creating invoice (mocked): ${invoice.invoiceNo}');
    await Future.delayed(const Duration(seconds: 1));
    // Return the same invoice with a mock ID, assuming creation was successful
    return invoice.copyWith(id: 'mock-created-${DateTime.now().millisecondsSinceEpoch}');
  }

  // Update an existing invoice
  Future<Invoice> updateInvoice(String id, Invoice invoice) async {
    // final response = await http.put(
    //   Uri.parse('$_baseUrl/$id'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(invoice.toJson()),
    // );
    // if (response.statusCode == 200) {
    //   return Invoice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    // } else {
    //   throw Exception('Failed to update invoice $id. Status: ${response.statusCode}, Body: ${response.body}');
    // }
    print('InvoiceService: Updating invoice $id (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    // Return the updated invoice, assuming update was successful
    return invoice;
  }

  // Delete an invoice
  Future<void> deleteInvoice(String id) async {
    // final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    // if (response.statusCode == 204) { // 204 No Content or 200 OK
    //   return;
    // } else {
    //   throw Exception('Failed to delete invoice $id. Status: ${response.statusCode}, Body: ${response.body}');
    // }
    print('InvoiceService: Deleting invoice $id (mocked)');
    await Future.delayed(const Duration(seconds: 1));
    // No return value needed for delete, or could return a boolean status
  }
}
