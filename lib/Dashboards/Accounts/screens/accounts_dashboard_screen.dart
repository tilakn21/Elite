import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_job_table.dart';

class AccountsDashboardScreen extends StatefulWidget {
  const AccountsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AccountsDashboardScreen> createState() => _AccountsDashboardScreenState();
}

class _AccountsDashboardScreenState extends State<AccountsDashboardScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['All', 'Paid', 'Pending', 'Overdue'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final List<Invoice> allJobs = invoiceProvider.invoices;
    
    // Filter jobs by selected tab and search query
    List<Invoice> filteredJobs = allJobs.where((invoice) {
      bool matchesTab = false;
      switch (selectedTab) {
        case 0:
          matchesTab = true; // All
          break;
        case 1:
          matchesTab = invoice.status == InvoiceStatus.paid;
          break;
        case 2:
          matchesTab = invoice.status == InvoiceStatus.pending;
          break;
        case 3:
          matchesTab = invoice.status == InvoiceStatus.overdue;
          break;
        default:
          matchesTab = true;
      }
      final query = _searchQuery.toLowerCase();
      final matchesSearch = invoice.clientName.toLowerCase().contains(query) ||
          invoice.id.toLowerCase().contains(query) ||
          invoice.invoiceNo.toLowerCase().contains(query);
      return matchesTab && (query.isEmpty || matchesSearch);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          const AccountsSidebar(selectedIndex: 0),
          Expanded(
            child: Column(
              children: [
                const AccountsTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                        const SizedBox(height: 24),
                        Row(
                          children: List.generate(
                            tabs.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: selectedTab == index ? const Color(0xFF232B3E) : const Color(0xFFF6F4FF),
                                  foregroundColor: selectedTab == index ? Colors.white : const Color(0xFF888FA6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size(110, 44),
                                ),
                                onPressed: () => setState(() => selectedTab = index),
                                child: Text(tabs[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Modern search bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search by client name, job ID, or invoice no...',
                              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        // Allow scrolling for overflow
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Approved designs ready for print', 
                                  style: TextStyle(
                                    color: Color(0xFF888FA6), 
                                    fontWeight: FontWeight.w500, 
                                    fontSize: 15
                                  )
                                ),
                                const SizedBox(height: 18),
                                if (invoiceProvider.isLoading)
                                  Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFEEEEF1)),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF232B3E)),
                                      ),
                                    ),
                                  )
                                else if (invoiceProvider.errorMessage != null)
                                  Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFEEEEF1)),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Color(0xFFDC2626),
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Error loading invoices',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            invoiceProvider.errorMessage!,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          TextButton.icon(
                                            onPressed: () => Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices(),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  AccountsJobTable(invoices: filteredJobs),
                              ],
                            ),
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
