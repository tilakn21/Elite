// Copied from Receptionist/providers/reimbursement_provider.dart
import 'package:flutter/foundation.dart';
import '../models/employee_reimbursement.dart';
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
      _reimbursements = await _reimbursementService.fetchReimbursementsFromSupabase();
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
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _submitMessage = null;
    notifyListeners();
  }
}
