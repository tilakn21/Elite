import 'package:flutter/material.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_invoice_table.dart';
import '../widgets/accounts_invoice_detail.dart';
import '../models/invoice.dart';

class AccountsInvoiceScreen extends StatefulWidget {
  const AccountsInvoiceScreen({super.key});

  @override
  State<AccountsInvoiceScreen> createState() => _AccountsInvoiceScreenState();
}

class _AccountsInvoiceScreenState extends State<AccountsInvoiceScreen> {
  Invoice? selectedInvoice;
  
  // Sample invoice data
  final List<Invoice> sampleInvoices = [
    Invoice.createNew(
      clientId: 'client_1',
      clientName: 'John Doe',
      issueDate: DateTime(2023, 5, 25),
      dueDate: DateTime(2023, 6, 24),
    ).copyWith(
      id: 'inv_001',
      invoiceNo: 'INV-001',
      subtotal: 1200.0,
      taxAmount: 0.0,
      discountAmount: 0.0,
      totalAmount: 1200.0,
      amountPaid: 0.0,
      balanceDue: 1200.0,
      status: InvoiceStatus.pending,
      items: [
        InvoiceItem(
          id: 'item_001',
          description: 'Website Development',
          quantity: 1.0,
          unitPrice: 1000.0,
          taxRate: 0.0,
        ),
        InvoiceItem(
          id: 'item_002',
          description: 'UI/UX Design',
          quantity: 1.0,
          unitPrice: 200.0,
          taxRate: 0.0,
        ),
      ],
    ),
    Invoice.createNew(
      clientId: 'client_2',
      clientName: 'Jane Smith',
      issueDate: DateTime(2023, 5, 24),
      dueDate: DateTime(2023, 6, 23),
    ).copyWith(
      id: 'inv_002',
      invoiceNo: 'INV-002',
      subtotal: 800.0,
      taxAmount: 50.50,
      discountAmount: 0.0,
      totalAmount: 850.50,
      amountPaid: 850.50,
      balanceDue: 0.0,
      status: InvoiceStatus.paid,
      paidDate: DateTime(2023, 5, 25),
      paymentMethod: 'Credit Card',
      items: [
        InvoiceItem(
          id: 'item_003',
          description: 'Mobile App Development',
          quantity: 1.0,
          unitPrice: 800.0,
          taxRate: 6.31, // 6.31% tax
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          const AccountsSidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                const AccountsTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invoice Managment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                              const SizedBox(height: 24),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: AccountsInvoiceTable(
                                    onSelectInvoice: (invoice) {
                                      setState(() {
                                        selectedInvoice = invoice;
                                      });
                                    },
                                    invoices: sampleInvoices,
                                    selectedInvoiceNo: selectedInvoice?.invoiceNo ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Payment Detail
                        Expanded(
                          flex: 5,
                          child: AccountsInvoiceDetail(
                            invoice: selectedInvoice,
                            onConfirmPayment: () {
                              if (selectedInvoice != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment confirmed for ${selectedInvoice!.clientName} (${selectedInvoice!.invoiceNo})')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
