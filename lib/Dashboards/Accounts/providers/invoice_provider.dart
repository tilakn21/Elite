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
    _selectedInvoice = null; // Clear previous selection
    notifyListeners();
    try {
      _selectedInvoice = await _invoiceService.getInvoiceById(id);
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
      await _invoiceService.createInvoice(invoice);
      await fetchInvoices(); // Refresh the list
      return true;
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
      await _invoiceService.updateInvoice(id, invoice);
      await fetchInvoices(); // Refresh the list
      // Optionally, re-fetch the selected invoice if it was the one updated
      if (_selectedInvoice?.id == id) {
        await fetchInvoiceById(id);
      }
      return true;
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
      await _invoiceService.deleteInvoice(id);
      await fetchInvoices(); // Refresh the list
      if (_selectedInvoice?.id == id) {
        _selectedInvoice = null; // Clear selection if deleted
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
