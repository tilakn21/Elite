// Service for handling API communication related to Invoices
import '../models/invoice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvoiceService {
  final _supabase = Supabase.instance.client;

  // Fetch all invoices from jobs table, including all JSONB fields
  Future<List<Invoice>> getInvoices() async {
    final response = await _supabase
        .from('jobs')
        .select()
        .not('salesperson', 'is', null)
        .order('created_at', ascending: false);
    // Print all jobs where salesperson is not null
    for (final job in response) {
      print('Job: ' + job.toString());
    }
    // After mapping all jobs, check for due==0 and status!=completed, and update if needed
    final List<Invoice> invoices = response.map<Invoice>((job) {
      String statusStr = job['status']?.toString().toLowerCase() ?? '';
      final accountant = job['accountant'] as Map<String, dynamic>?;
      final double accountantDue = (accountant?['amount_due'] as num?)?.toDouble() ?? 0.0;
      final String accStatus = (accountant?['status'] as String?)?.toLowerCase() ?? '';
      if (accountant != null && accountantDue == 0 && accStatus != 'completed') {
        // Fire and forget, do not await
        _supabase.from('jobs').update({
          'accountant': {
            ...accountant,
            'status': 'completed',
          }
        }).eq('id', job['id']).select();
        accountant['status'] = 'completed';
      }
      // Map accountant JSONB fields
      final double accountantTotal = (accountant?['total_amount'] as num?)?.toDouble() ?? 0.0;
      final double accountantPaid = (accountant?['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final List<dynamic> payments = (accountant != null && accountant['payments'] is List) ? List<dynamic>.from(accountant['payments']) : [];
      // Get client name from receptionist jsonb if available
      String clientName = '';
      if (job['receptionist'] is Map<String, dynamic> && job['receptionist'] != null) {
        clientName = (job['receptionist']['customerName'] ?? '').toString();
      }
      // Fix: fallback for issueDate and dueDate
      DateTime issueDate = DateTime.now();
      if (job['created_at'] != null) {
        try {
          issueDate = DateTime.parse(job['created_at']);
        } catch (_) {}
      }
      DateTime dueDate = issueDate;
      if (job['due_date'] != null) {
        try {
          dueDate = DateTime.parse(job['due_date']);
        } catch (_) {}
      }
      return Invoice(
        id: job['id'].toString(), // Use job id as job id
        invoiceNo: job['id'].toString(), // Use job id for display
        clientId: job['client_id']?.toString() ?? '',
        clientName: clientName.isNotEmpty ? clientName : (job['client_name']?.toString() ?? ''),
        issueDate: issueDate,
        dueDate: dueDate,
        subtotal: (job['subtotal'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (job['tax_amount'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (job['discount_amount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: accountantTotal > 0 ? accountantTotal : (job['total_amount'] as num?)?.toDouble() ?? 0.0,
        amountPaid: accountantPaid > 0 ? accountantPaid : (job['amount_paid'] as num?)?.toDouble() ?? 0.0,
        balanceDue: accountantDue > 0 ? accountantDue : (job['balance_due'] as num?)?.toDouble() ?? 0.0,
        status: InvoiceStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => InvoiceStatus.draft,
        ),
        paidDate: job['paid_date'] != null ? DateTime.tryParse(job['paid_date']) : null,
        paymentMethod: job['payment_method']?.toString(),
        items: (job['invoice_items'] is List)
            ? (job['invoice_items'] as List).map<InvoiceItem>((item) => InvoiceItem.fromJson(item)).toList()
            : [],
        accountantJson: accountant,
        payments: payments,
      );
    }).toList();
    return invoices;
  }

  Future<void> appendAccountantPaymentDetail({
    required String jobId,
    required Map<String, dynamic> paymentDetail,
  }) async {
    // Fetch current accountant JSONB
    final job = await _supabase.from('jobs').select('accountant').eq('id', jobId).single();
    Map<String, dynamic> accountant = {};
    if (job['accountant'] != null) {
      accountant = Map<String, dynamic>.from(job['accountant']);
    }
    // Update amount_paid and amount_due
    final double prevPaid = (accountant['amount_paid'] ?? 0).toDouble();
    final double prevDue = (accountant['amount_due'] ?? 0).toDouble();
    final double totalAmount = (accountant['total_amount'] ?? 0).toDouble();
    final double paymentAmount = (paymentDetail['amount_paid'] ?? 0).toDouble();
    final double newPaid = prevPaid + paymentAmount;
    final double newDue = (prevDue - paymentAmount).clamp(0, totalAmount);
    accountant['amount_paid'] = newPaid;
    accountant['amount_due'] = newDue;
    // Append payment record with separate date and time fields
    final paymentRecord = {
      'amount': paymentAmount,
      'received_by': paymentDetail['received_by'],
      'mode_of_payment': paymentDetail['mode_of_payment'],
      'date': paymentDetail['date'],
      'time': paymentDetail['time'],
    };
    if (accountant['payments'] == null || accountant['payments'] is! List) {
      accountant['payments'] = [paymentRecord];
    } else {
      (accountant['payments'] as List).add(paymentRecord);
    }
    // Set status to completed in accountant JSONB
    accountant['status'] = paymentDetail['status'] ?? 'completed';
    // Update jobs table
    await _supabase.from('jobs').update({'accountant': accountant}).eq('id', jobId).select();
  }
}
