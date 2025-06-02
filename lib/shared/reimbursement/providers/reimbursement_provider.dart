import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/reimbursement_model.dart';
import '../services/reimbursement_service.dart';

class ReimbursementProvider with ChangeNotifier {
  final ReimbursementService _service;
  List<EmployeeReimbursement> _reimbursements = [];
  
  ReimbursementProvider(this._service) {
    fetchReimbursements();
  }
  
  List<EmployeeReimbursement> get reimbursements => _reimbursements;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _submitMessage;
  String? get submitMessage => _submitMessage;

  int get pendingReimbursementsCount =>
      _reimbursements.where((r) => r.status == ReimbursementStatus.pending).length;

  double get totalPendingAmount =>
      _reimbursements
          .where((r) => r.status == ReimbursementStatus.pending)
          .fold(0.0, (sum, r) => sum + r.amount);

  double get totalApprovedAmount =>
      _reimbursements
          .where((r) => r.status == ReimbursementStatus.approved)
          .fold(0.0, (sum, r) => sum + r.amount);

  double get totalPaidAmount =>
      _reimbursements
          .where((r) => r.status == ReimbursementStatus.paid)
          .fold(0.0, (sum, r) => sum + r.amount);
          
  Map<ReimbursementStatus, List<EmployeeReimbursement>> get groupedReimbursements {
    final Map<ReimbursementStatus, List<EmployeeReimbursement>> map = {};
    for (var status in ReimbursementStatus.values) {
      map[status] = _reimbursements.where((r) => r.status == status).toList();
    }
    return map;
  }

  Future<void> fetchReimbursements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reimbursements = await _service.fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<EmployeeReimbursement>> fetchEmployeeReimbursements(String empId) async {
    try {
      return await _service.fetchReimbursementsByEmployee(empId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> addReimbursementRequest(EmployeeReimbursement reimbursement, {File? receiptImage}) async {
    _isLoading = true;
    _errorMessage = null;
    _submitMessage = null;
    notifyListeners();

    try {
      await _service.addReimbursementRequest(reimbursement, receiptImage: receiptImage);
      _submitMessage = 'Reimbursement request submitted successfully!';
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? remarks}) async {
    final current = _getReimbursementById(id);
    if (current == null) {
      _errorMessage = 'Reimbursement not found';
      notifyListeners();
      return;
    }

    if (!_isValidStatusTransition(current.status, status)) {
      _errorMessage = 'Invalid status transition: ${current.status} -> $status';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateReimbursementStatus(id, status, adminRemarks: remarks);
      await fetchReimbursements();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidStatusTransition(ReimbursementStatus currentStatus, ReimbursementStatus newStatus) {
    switch (currentStatus) {
      case ReimbursementStatus.pending:
        return newStatus == ReimbursementStatus.approved || 
               newStatus == ReimbursementStatus.rejected;
      case ReimbursementStatus.approved:
        return newStatus == ReimbursementStatus.paid;
      case ReimbursementStatus.rejected:
      case ReimbursementStatus.paid:
        return false; // Cannot transition from rejected or paid
    }
  }

  EmployeeReimbursement? _getReimbursementById(String id) {
    try {
      return _reimbursements.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<EmployeeReimbursement> getReimbursementsByStatus(ReimbursementStatus status) {
    return _reimbursements.where((r) => r.status == status).toList();
  }

  List<EmployeeReimbursement> getReimbursementsByEmployee(String empId) {
    return _reimbursements.where((r) => r.empId == empId).toList();
  }

  List<EmployeeReimbursement> searchReimbursements(String query) {
    if (query.isEmpty) return _reimbursements;
    
    final lowercaseQuery = query.toLowerCase();
    return _reimbursements.where((r) =>
      r.empName.toLowerCase().contains(lowercaseQuery) ||
      r.purpose.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Map<ReimbursementStatus, int> get statusCounts {
    final Map<ReimbursementStatus, int> counts = {};
    for (var status in ReimbursementStatus.values) {
      counts[status] = _reimbursements.where((r) => r.status == status).length;
    }
    return counts;
  }

  double getTotalAmountByStatus(ReimbursementStatus status) {
    return _reimbursements
      .where((r) => r.status == status)
      .fold(0.0, (sum, r) => sum + r.amount);
  }

  void clearMessages() {
    _errorMessage = null;
    _submitMessage = null;
    notifyListeners();
  }
}
