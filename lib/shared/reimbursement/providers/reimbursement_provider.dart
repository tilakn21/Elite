import 'package:flutter/foundation.dart';
import '../models/reimbursement_model.dart';
import '../services/reimbursement_service.dart';
import 'dart:io';

class ReimbursementProvider with ChangeNotifier {
  final ReimbursementService _reimbursementService;

  ReimbursementProvider(this._reimbursementService) {
    fetchReimbursements();
  }

  List<EmployeeReimbursement> _reimbursements = [];
  List<EmployeeReimbursement> get reimbursements => _reimbursements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _submitMessage;
  String? get submitMessage => _submitMessage;

  /// Fetch all reimbursement requests
  Future<void> fetchReimbursements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _reimbursements = await _reimbursementService.fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new reimbursement request
  Future<void> addReimbursementRequest(EmployeeReimbursement reimbursement, {File? receiptImage}) async {
    _isSubmitting = true;
    _errorMessage = null;
    _submitMessage = null;
    notifyListeners();
    
    try {
      await _reimbursementService.addReimbursementRequest(reimbursement, receiptImage: receiptImage);
      _submitMessage = 'Reimbursement request submitted successfully!';
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
      _submitMessage = 'Failed to submit reimbursement request. Please try again.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update reimbursement status (for admin/manager use)
  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? adminRemarks}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _reimbursementService.updateReimbursementStatus(id, status, adminRemarks: adminRemarks);
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _submitMessage = null;
    notifyListeners();
  }

  /// Get pending reimbursements count
  int get pendingReimbursementsCount {
    return _reimbursements.where((r) => r.status == ReimbursementStatus.pending).length;
  }

  /// Get total amount for approved reimbursements
  double get totalApprovedAmount {
    return _reimbursements
        .where((r) => r.status == ReimbursementStatus.approved)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  /// Search reimbursements by employee name or purpose
  List<EmployeeReimbursement> searchReimbursements(String query) {
    if (query.isEmpty) return _reimbursements;
    
    final lowercaseQuery = query.toLowerCase();
    return _reimbursements.where((r) =>
      r.empName.toLowerCase().contains(lowercaseQuery) ||
      r.purpose.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
