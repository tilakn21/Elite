import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee_payment.dart';
import '../providers/employee_provider.dart';
import '../widgets/accounts_sidebar.dart';
import '../widgets/accounts_top_bar.dart';
import '../widgets/accounts_employee_table.dart';
import '../widgets/reimbursement_details_dialog.dart';

class AccountsEmployeeScreen extends StatefulWidget {
  const AccountsEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AccountsEmployeeScreen> createState() => _AccountsEmployeeScreenState();
}

class _AccountsEmployeeScreenState extends State<AccountsEmployeeScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['All', 'Paid', 'Pending', 'Rejected'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeePayments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final List<EmployeePayment> allPayments = employeeProvider.payments;
    
    // Filter payments by selected tab and search query
    List<EmployeePayment> filteredPayments = allPayments.where((payment) {
      bool matchesTab = false;
      switch (selectedTab) {
        case 0:
          matchesTab = true; // All
          break;
        case 1:
          matchesTab = payment.status == PaymentStatus.paid;
          break;
        case 2:
          matchesTab = payment.status == PaymentStatus.pending;
          break;
        case 3:
          matchesTab = payment.status == PaymentStatus.rejected;
          break;
        default:
          matchesTab = true;
      }
      
      final query = _searchQuery.toLowerCase();
      final matchesSearch = payment.empName.toLowerCase().contains(query) ||
          payment.empId.toLowerCase().contains(query) ||
          payment.purpose.toLowerCase().contains(query);
      
      return matchesTab && (query.isEmpty || matchesSearch);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          const AccountsSidebar(selectedIndex: 2),
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
                        const Text('Reimbursement Requests', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 28
                          )
                        ),
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
                              hintText: 'Search by employee name, ID, or purpose...',
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
                                const Text(
                                  'Employee Reimbursement Requests', 
                                  style: TextStyle(
                                    color: Color(0xFF888FA6),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (employeeProvider.isLoading)
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
                                else if (employeeProvider.errorMessage != null)
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
                                            'Error loading reimbursement requests',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            employeeProvider.errorMessage!,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          TextButton.icon(
                                            onPressed: () => Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeePayments(),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  AccountsEmployeeTable(
                                    payments: filteredPayments,
                                    onViewDetails: (payment) async {
                                      // Show reimbursement details dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) => ReimbursementDetailsDialog(
                                          reimbursement: payment,
                                          onConfirmPayment: (paymentId) async {
                                            try {
                                              await employeeProvider.confirmPayment(paymentId);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.check_circle, color: Colors.white),
                                                        SizedBox(width: 12),
                                                        Text('Payment confirmed successfully'),
                                                      ],
                                                    ),
                                                    backgroundColor: Color(0xFF059669),
                                                    behavior: SnackBarBehavior.floating,
                                                    margin: EdgeInsets.all(16),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(Icons.error_outline, color: Colors.white),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(e.toString()),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior.floating,
                                                    margin: const EdgeInsets.all(16),
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                                    ),
                                                  ),
                                                );
                                              }
                                              rethrow;
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
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
