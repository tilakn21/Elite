import 'package:flutter/material.dart';
import '../models/employee_payment.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class ReimbursementDetailsDialog extends StatefulWidget {
  final EmployeePayment reimbursement;
  final Function(String) onConfirmPayment;

  const ReimbursementDetailsDialog({
    Key? key,
    required this.reimbursement,
    required this.onConfirmPayment,
  }) : super(key: key);

  @override
  State<ReimbursementDetailsDialog> createState() => _ReimbursementDetailsDialogState();
}

class _ReimbursementDetailsDialogState extends State<ReimbursementDetailsDialog> {
  bool _isLoading = false;
  bool _isImageViewerOpen = false;
  String? _error;

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.paid:
        return const Color(0xFF059669);
      case PaymentStatus.approved:
        return const Color(0xFF16A34A);
      case PaymentStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.approved:
        return Icons.check;
      case PaymentStatus.rejected:
        return Icons.cancel;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleConfirmPayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await widget.onConfirmPayment(widget.reimbursement.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed successfully'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildReceiptViewer() {
    if (widget.reimbursement.receiptUrl == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => setState(() => _isImageViewerOpen = true),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.reimbursement.receiptUrl!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isImageViewerOpen && widget.reimbursement.receiptUrl != null) {
      return Dialog.fullscreen(
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(widget.reimbursement.receiptUrl!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => setState(() => _isImageViewerOpen = false),
              ),
            ),
          ],
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF36A1C5), Color(0xFF5B86E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reimbursement Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.reimbursement.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(widget.reimbursement.status),
                              color: _getStatusColor(widget.reimbursement.status),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.reimbursement.status.name.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(widget.reimbursement.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currencyFormatter.format(widget.reimbursement.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.person,
                    'Employee Name',
                    widget.reimbursement.empName,
                  ),
                  _buildDetailRow(
                    Icons.numbers,
                    'Employee ID',
                    widget.reimbursement.empId,
                  ),
                  _buildDetailRow(
                    Icons.description,
                    'Purpose',
                    widget.reimbursement.purpose,
                  ),
                  _buildDetailRow(
                    Icons.date_range,
                    'Date',
                    dateFormatter.format(widget.reimbursement.reimbursementDate),
                  ),
                  if (widget.reimbursement.remarks != null)
                    _buildDetailRow(
                      Icons.comment,
                      'Remarks',
                      widget.reimbursement.remarks!,
                    ),
                  if (widget.reimbursement.receiptUrl != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Receipt',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildReceiptViewer(),
                  ],
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.reimbursement.status == PaymentStatus.approved) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleConfirmPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B86E5),
                            disabledBackgroundColor: const Color(0xFF5B86E5).withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Processing Payment...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Confirm Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
