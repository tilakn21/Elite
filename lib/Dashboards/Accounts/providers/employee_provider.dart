import 'package:flutter/material.dart';
import '../models/employee_payment.dart';
import '../services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();

  List<EmployeePayment> _payments = [];
  EmployeePayment? _selectedPayment;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConfirmingPayment = false;

  List<EmployeePayment> get payments => _payments;
  EmployeePayment? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  bool get isConfirmingPayment => _isConfirmingPayment;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEmployeePayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _payments = await _employeeService.getEmployeePayments();
    } catch (e) {
      _errorMessage = e.toString();
      _payments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void selectPayment(EmployeePayment? payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  Future<void> confirmPayment(String paymentId) async {
    _isConfirmingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payment = _payments.firstWhere((p) => p.id == paymentId);
      final updatedPayment = EmployeePayment(
        id: payment.id,
        empId: payment.empId,
        empName: payment.empName,
        amount: payment.amount,
        reimbursementDate: payment.reimbursementDate,
        purpose: payment.purpose,
        receiptUrl: payment.receiptUrl,
        status: PaymentStatus.paid,
        remarks: payment.remarks,
        createdAt: payment.createdAt,
      );
      
      await updatePayment(paymentId, updatedPayment);
      await fetchEmployeePayments(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to confirm payment: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isConfirmingPayment = false;
      notifyListeners();
    }
  }

  Future<bool> updatePayment(String id, EmployeePayment payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _employeeService.updateEmployeePayment(id, payment);
      await fetchEmployeePayments();
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
