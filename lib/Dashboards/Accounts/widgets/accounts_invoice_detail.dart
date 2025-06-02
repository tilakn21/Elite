import 'package:flutter/material.dart';
import '../models/invoice.dart';

class AccountsInvoiceDetail extends StatelessWidget {
  final Invoice? invoice;
  final VoidCallback onConfirmPayment;
  const AccountsInvoiceDetail({super.key, this.invoice, required this.onConfirmPayment});

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text('Select an invoice to view details', style: TextStyle(fontSize: 16, color: Color(0xFF888FA6))),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice header with job ID and client
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job ID: #${invoice!.id}', 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 24, 
                        color: Color(0xFF232B3E)
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(invoice!.clientName, 
                      style: const TextStyle(
                        fontSize: 18, 
                        color: Color(0xFF6B7280)
                      )
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(invoice!.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatStatus(invoice!.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _getStatusTextColor(invoice!.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Date and amount section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Issued', 
                        style: TextStyle(
                          fontSize: 14, 
                          color: Color(0xFF6B7280)
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${invoice!.issueDate.day}/${invoice!.issueDate.month}/${invoice!.issueDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                if (invoice!.accountantJson != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Amount', 
                          style: TextStyle(
                            fontSize: 14, 
                            color: Color(0xFF6B7280)
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(invoice!.accountantJson!['total_amount'] as num).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Payment details
          if (invoice!.accountantJson != null) ...[
            Text('Payment Details', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF232B3E),
              )
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount Paid', 
                          style: TextStyle(
                            fontSize: 14, 
                            color: Color(0xFF6B7280)
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(invoice!.accountantJson!['amount_paid'] as num).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount Due', 
                          style: TextStyle(
                            fontSize: 14, 
                            color: Color(0xFF6B7280)
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(invoice!.accountantJson!['amount_due'] as num).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Payment history
          if (invoice!.payments.isNotEmpty) ...[
            Text('Payment History', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF232B3E),
              )
            ),
            const SizedBox(height: 16),
            ...invoice!.payments.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 20, color: Color(0xFF6B7280)),
                              const SizedBox(width: 8),
                              Text(
                                '\$${p['amount']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p['mode_of_payment'] ?? p['mode'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${p['date']} ${p['time']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 8),
                        Text(
                          'Received by: ${p['received_by'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 32),

          // Confirm payment button
          if ((invoice!.accountantJson?['amount_due'] ?? 0) > 0) 
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: onConfirmPayment,
                child: const Text(
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFFD0F8E6);
      case InvoiceStatus.pending:
        return const Color(0xFFFFEAEA);
      case InvoiceStatus.overdue:
        return const Color(0xFFF3EFFF);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF059669);
      case InvoiceStatus.pending:
        return const Color(0xFFF96E6E);
      case InvoiceStatus.overdue:
        return const Color(0xFF9B6FF7);
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatStatus(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.partial:
        return 'Partial';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      default:
        return status.toString().split('.').last[0].toUpperCase() + 
               status.toString().split('.').last.substring(1);
    }
  }
}
