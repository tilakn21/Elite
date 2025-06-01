import 'package:flutter/foundation.dart';
import '../models/employee_reimbursement.dart';

class ReimbursementProvider with ChangeNotifier {
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
      _reimbursements.where((r) => r.status == ReimbursementStatus.approved).fold(0.0, (sum, r) => sum + r.amount);

  Future<void> fetchReimbursements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with real backend call
    _reimbursements = [
      EmployeeReimbursement(
        empId: 'E001',
        empName: 'John Doe',
        amount: 120.5,
        reimbursementDate: DateTime.now().subtract(const Duration(days: 2)),
        purpose: 'Travel',
        status: ReimbursementStatus.pending,
      ),
      EmployeeReimbursement(
        empId: 'E002',
        empName: 'Jane Smith',
        amount: 80.0,
        reimbursementDate: DateTime.now().subtract(const Duration(days: 5)),
        purpose: 'Supplies',
        status: ReimbursementStatus.approved,
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateReimbursementStatus(String id, ReimbursementStatus status) async {
    final idx = _reimbursements.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reimbursements[idx] = EmployeeReimbursement(
        id: _reimbursements[idx].id,
        empId: _reimbursements[idx].empId,
        empName: _reimbursements[idx].empName,
        amount: _reimbursements[idx].amount,
        reimbursementDate: _reimbursements[idx].reimbursementDate,
        purpose: _reimbursements[idx].purpose,
        receiptUrl: _reimbursements[idx].receiptUrl,
        remarks: _reimbursements[idx].remarks,
        status: status,
        createdAt: _reimbursements[idx].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
