import 'package:flutter/foundation.dart';
import '../models/employee_reimbursement.dart';
import '../services/reimbursement_service.dart';

class ReimbursementProvider with ChangeNotifier {
  final ReimbursementService _service = ReimbursementService();
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

  int get pendingReimbursementsCount =>
      _reimbursements.where((r) => r.status == ReimbursementStatus.pending).length;
  double get totalApprovedAmount =>
      _reimbursements
          .where((r) => r.status == ReimbursementStatus.approved || r.status == ReimbursementStatus.paid)
          .fold(0.0, (sum, r) => sum + r.amount);

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

  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status, {String? remarks}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateReimbursementStatus(id, status, remarks: remarks);
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveReimbursement(String id, {String? remarks}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.approveReimbursement(id, remarks: remarks);
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> declineReimbursement(String id, {String? remarks}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.declineReimbursement(id, remarks: remarks);
      await fetchReimbursements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<EmployeeReimbursement> get visibleReimbursements =>
      _reimbursements.where((r) =>
        r.status == ReimbursementStatus.pending ||
        r.status == ReimbursementStatus.approved ||
        r.status == ReimbursementStatus.rejected ||
        r.status == ReimbursementStatus.paid
      ).toList();
}
