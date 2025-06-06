import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  String? _errorMessage;

  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _invoices = await _invoiceService.getInvoices();
    } catch (e) {
      _errorMessage = e.toString();
      _invoices = []; // Clear invoices on error or set to a default state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInvoiceById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedInvoice = null;
    notifyListeners();
    try {
      // Remove call to _invoiceService.getInvoiceById, as it no longer exists
      // Instead, fetch all invoices and select the one with the matching id
      await fetchInvoices();
      _selectedInvoice = _invoices.firstWhere(
        (inv) => inv.id == id,
        orElse: () => Invoice(
          id: '',
          invoiceNo: '',
          clientId: '',
          clientName: '',
          issueDate: DateTime.now(),
          dueDate: DateTime.now(),
          subtotal: 0.0,
          taxAmount: 0.0,
          discountAmount: 0.0,
          totalAmount: 0.0,
          amountPaid: 0.0,
          balanceDue: 0.0,
          status: InvoiceStatus.draft,
          items: [],
        ),
      );
      if (_selectedInvoice?.id == '') _selectedInvoice = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectInvoice(Invoice? invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  Future<bool> createInvoice(Invoice invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Remove call to _invoiceService.createInvoice, as it no longer exists
      // Optionally, implement creation logic if needed, or just return false
      // For now, just return false and set error message
      _errorMessage = 'Invoice creation is not supported.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInvoice(String id, Invoice invoice) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Remove call to _invoiceService.updateInvoice, as it no longer exists
      _errorMessage = 'Invoice update is not supported.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInvoice(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Remove call to _invoiceService.deleteInvoice, as it no longer exists
      _errorMessage = 'Invoice deletion is not supported.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> appendAccountantPaymentDetail({
    required String jobId,
    required Map<String, dynamic> paymentDetail,
  }) async {
    await _invoiceService.appendAccountantPaymentDetail(jobId: jobId, paymentDetail: paymentDetail);
    await fetchInvoices(); // Refresh data after update
  }

  Future<void> updateJobStatusOutForDeliveryIfPaymentPending(String jobId) async {
    await _invoiceService.updateJobStatusOutForDeliveryIfPaymentPending(jobId);
    await fetchInvoices();
  }
}
