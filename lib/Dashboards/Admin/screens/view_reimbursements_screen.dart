import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../models/employee_reimbursement.dart';
import '../providers/reimbursement_provider.dart';

class ViewReimbursementsScreen extends StatefulWidget {
  const ViewReimbursementsScreen({Key? key}) : super(key: key);

  @override
  State<ViewReimbursementsScreen> createState() => _ViewReimbursementsScreenState();
}

class _ViewReimbursementsScreenState extends State<ViewReimbursementsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  
  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    // Refresh reimbursement data when screen is opened
    Future.microtask(() {
      Provider.of<ReimbursementProvider>(context, listen: false).fetchReimbursements();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    int sidebarIndex = 5; // Set to the correct index for reimbursements in AdminSidebar (add a button if needed)

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: sidebarIndex,
                onItemTapped: (idx) {
                  // Optionally handle navigation here
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: sidebarIndex,
              onItemTapped: (idx) {
                // Optionally handle navigation here
              },
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminTopBar(),
                Expanded(
                  child: Consumer<ReimbursementProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final filteredReimbursements = _getFilteredReimbursements(provider.reimbursements);

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header and statistics
                              _buildHeader(provider),
                              const SizedBox(height: 24),
                              
                              // Statistics cards
                              _buildStatisticsCards(provider, isMobile),
                              const SizedBox(height: 32),
                              
                              // Search and filter section
                              _buildSearchAndFilter(isMobile),
                              const SizedBox(height: 24),
                              
                              // Reimbursements table
                              _ReimbursementsTable(
                                reimbursements: filteredReimbursements,
                                isMobile: isMobile,
                                onStatusUpdate: (id, status) => _updateStatus(id, status, provider),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ReimbursementProvider provider) {
    return Row(
      children: [
        Icon(Icons.receipt_long, size: 28, color: const Color(0xFF1B2330)),
        SizedBox(width: 12),
        Text(
          'Reimbursement Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2330),
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: provider.fetchReimbursements,
          icon: Icon(Icons.refresh, color: const Color(0xFF1B2330)),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(ReimbursementProvider provider, bool isMobile) {
    return isMobile 
        ? Column(
            children: [
              _StatCard(
                title: 'Pending Requests',
                value: provider.pendingReimbursementsCount.toString(),
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'Total Approved Amount',
                value: '\$${provider.totalApprovedAmount.toStringAsFixed(2)}',
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'Total Requests',
                value: provider.reimbursements.length.toString(),
                icon: Icons.receipt,
                color: Colors.blue,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Pending Requests',
                  value: provider.pendingReimbursementsCount.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Approved Amount',
                  value: '\$${provider.totalApprovedAmount.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Requests',
                  value: provider.reimbursements.length.toString(),
                  icon: Icons.receipt,
                  color: Colors.blue,
                ),
              ),
            ],
          );
  }

  Widget _buildSearchAndFilter(bool isMobile) {
    return isMobile 
        ? Column(
            children: [
              // Search bar
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by employee name or purpose...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              SizedBox(height: 12),
              
              // Status filter
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                    items: ['All', 'Pending', 'Approved', 'Rejected']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          )
        : Row(
            children: [
              // Search bar
              Expanded(
                flex: 2,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by employee name or purpose...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Status filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    isExpanded: false,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                    items: ['All', 'Pending', 'Approved', 'Rejected']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
  }

  List<EmployeeReimbursement> _getFilteredReimbursements(List<EmployeeReimbursement> reimbursements) {
    return reimbursements.where((reimbursement) {
      final matchesSearch = searchQuery.isEmpty ||
          reimbursement.empName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          reimbursement.purpose.toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Pending' && reimbursement.status == ReimbursementStatus.pending) ||
          (selectedStatus == 'Approved' && reimbursement.status == ReimbursementStatus.approved) ||
          (selectedStatus == 'Rejected' && reimbursement.status == ReimbursementStatus.rejected);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _updateStatus(String id, ReimbursementStatus status, ReimbursementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status'),
        content: Text('Are you sure you want to \\${status.toString().split('.').last} this reimbursement request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.updateReimbursementStatus(id, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == ReimbursementStatus.approved ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2330),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF7B7B7B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReimbursementsTable extends StatelessWidget {
  final List<EmployeeReimbursement> reimbursements;
  final bool isMobile;
  final Function(String, ReimbursementStatus) onStatusUpdate;

  const _ReimbursementsTable({
    required this.reimbursements,
    required this.isMobile,
    required this.onStatusUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: reimbursements
            .map((reimbursement) => _MobileReimbursementCard(
                  reimbursement: reimbursement,
                  onStatusUpdate: onStatusUpdate,
                ))
            .toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F7FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Employee', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 14))),
                Expanded(flex: 1, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 14))),
                Expanded(flex: 2, child: Text('Purpose', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 14))),
                Expanded(flex: 1, child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 14))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 14))),
                SizedBox(width: 80), // Actions column
              ],
            ),
          ),
          
          // Table rows
          ...reimbursements.map((reimbursement) => _DesktopReimbursementRow(
                reimbursement: reimbursement,
                onStatusUpdate: onStatusUpdate,
              )),
        ],
      ),
    );
  }
}

class _MobileReimbursementCard extends StatelessWidget {
  final EmployeeReimbursement reimbursement;
  final Function(String, ReimbursementStatus) onStatusUpdate;

  const _MobileReimbursementCard({
    required this.reimbursement,
    required this.onStatusUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reimbursement.empName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF1B2330),
                  ),
                ),
              ),
              _StatusBadge(status: reimbursement.status),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '\$${reimbursement.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.green[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            reimbursement.purpose,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF7B7B7B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${reimbursement.reimbursementDate.day.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.month.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.year}',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFBDBDBD),
            ),
          ),
          if (reimbursement.status == ReimbursementStatus.pending) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate(reimbursement.id, ReimbursementStatus.approved),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Approve'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate(reimbursement.id, ReimbursementStatus.rejected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopReimbursementRow extends StatelessWidget {
  final EmployeeReimbursement reimbursement;
  final Function(String, ReimbursementStatus) onStatusUpdate;

  const _DesktopReimbursementRow({
    required this.reimbursement,
    required this.onStatusUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reimbursement.empName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    reimbursement.empId,
                    style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '\$${reimbursement.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green[600],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                reimbursement.purpose,
                style: TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${reimbursement.reimbursementDate.day.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.month.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.year}',
                style: TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)),
              ),
            ),
            Expanded(
              flex: 1,
              child: _StatusBadge(status: reimbursement.status),
            ),
            SizedBox(
              width: 80,
              child: reimbursement.status == ReimbursementStatus.pending
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: () => onStatusUpdate(reimbursement.id, ReimbursementStatus.approved),
                          icon: Icon(Icons.check, color: Colors.green, size: 20),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          onPressed: () => onStatusUpdate(reimbursement.id, ReimbursementStatus.rejected),
                          icon: Icon(Icons.close, color: Colors.red, size: 20),
                          tooltip: 'Reject',
                        ),
                      ],
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reimbursement Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Employee', reimbursement.empName),
              _DetailRow('Employee ID', reimbursement.empId),
              _DetailRow('Amount', '\$${reimbursement.amount.toStringAsFixed(2)}'),
              _DetailRow('Purpose', reimbursement.purpose),
              _DetailRow('Date', '${reimbursement.reimbursementDate.day.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.month.toString().padLeft(2, '0')}/${reimbursement.reimbursementDate.year}'),
              _DetailRow('Status', reimbursement.statusString),
              if (reimbursement.remarks != null)
                _DetailRow('Remarks', reimbursement.remarks!),
              if (reimbursement.receiptUrl != null)
                _DetailRow('Receipt', 'Available'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReimbursementStatus status;

  const _StatusBadge({required this.status, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case ReimbursementStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        text = 'Pending';
        break;
      case ReimbursementStatus.approved:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        text = 'Approved';
        break;
      case ReimbursementStatus.rejected:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

Widget _DetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400))),
      ],
    ),
  );
}
