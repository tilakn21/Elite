import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_request.dart';
import '../models/salesperson.dart' as model;
import '../providers/job_request_provider.dart';
import '../providers/salesperson_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../services/receptionist_service.dart';

class AssignSalespersonScreen extends StatefulWidget {
  const AssignSalespersonScreen({Key? key}) : super(key: key);

  @override
  State<AssignSalespersonScreen> createState() => _AssignSalespersonScreenState();
}

class _AssignSalespersonScreenState extends State<AssignSalespersonScreen> {
  String? selectedJobId;
  String? selectedSalespersonId;
  bool isAssigning = false;
  String? assignMessage;

  String _receptionistName = '';
  String _branchName = '';
  String _receptionistId = 'rec1001'; // fallback for demo, replace with actual auth id

  @override
  void initState() {
    super.initState();
    _fetchReceptionistAndBranch();
  }

  Future<void> _fetchReceptionistAndBranch() async {
    final service = ReceptionistService();
    final details = await service.fetchReceptionistDetails(receptionistId: _receptionistId);
    String name = details?['full_name'] ?? '';
    String branchName = '';
    String id = details?['id'] ?? 'rec1001';
    if (details != null && details['branch_id'] != null) {
      branchName = await service.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
    }
    setState(() {
      _receptionistName = name;
      _branchName = branchName;
      _receptionistId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 420;
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final salespersonProvider = Provider.of<SalespersonProvider>(context);
    final jobs = jobRequestProvider.jobRequests.where((job) => job.assigned != true).toList();
    final salesPeople = salespersonProvider.salespersons.where((sp) => sp.status == model.SalespersonStatus.available).toList();
    final bool isLoading = jobRequestProvider.isLoading || salespersonProvider.isLoading;
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF6F3FE),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: 2,
                isDrawer: true,
                onClose: () => Navigator.of(context).pop(),
                employeeId: _receptionistId,
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 2, employeeId: _receptionistId),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                  receptionistName: _receptionistName.isNotEmpty ? _receptionistName : 'Receptionist',
                  branchName: _branchName.isNotEmpty ? _branchName : 'Branch',
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 56, top: 8),
                                  child: Text(
                                    'Assign salesperson',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: Color(0xFF1B2330),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 56),
                                    // Job list card
                                    Container(
                                      width: cardWidth,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(10),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Job list',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xFF7B7B7B))),
                                          const SizedBox(height: 16),
                                          if (jobs.isEmpty)
                                            const Text('No unassigned jobs.', style: TextStyle(color: Colors.red)),
                                          ...jobs.map((job) => _JobListItem(
                                                job: job,
                                                selected: selectedJobId == job.id,
                                                onTap: () {
                                                  setState(() {
                                                    selectedJobId = job.id;
                                                    assignMessage = null;
                                                  });
                                                },
                                              )),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    // Salesperson availability card
                                    Container(
                                      width: cardWidth,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(10),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Salesperson availability',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xFF7B7B7B))),
                                          const SizedBox(height: 16),
                                          _SalespersonDropdown(
                                            salesPeople: salesPeople,
                                            selectedId: selectedSalespersonId,
                                            onChanged: (id) {
                                              setState(() {
                                                selectedSalespersonId = id;
                                                assignMessage = null;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          ...salesPeople.map((sp) => _SalespersonItem(name: sp.name)).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 48),
                                Padding(
                                  padding: const EdgeInsets.only(left: 56),
                                  child: Container(
                                    width: 900,
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Assign Job ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1B2330),
                                                  fontSize: 16),
                                              children: [
                                                TextSpan(
                                                    text: selectedJobId != null
                                                        ? '#${selectedJobId!}'
                                                        : 'Select a job',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF36A1C5))),
                                                const TextSpan(text: ' to '),
                                                TextSpan(
                                                    text: selectedSalespersonId != null
                                                        ? salesPeople.firstWhere((sp) => sp.id == selectedSalespersonId, orElse: () => model.Salesperson(name: '', status: model.SalespersonStatus.available)).name
                                                        : 'Select a salesperson',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF36A1C5))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          height: 32,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF36A1C5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: (selectedJobId != null && selectedSalespersonId != null && !isAssigning)
                                                ? () async {
                                                    setState(() {
                                                      isAssigning = true;
                                                      assignMessage = null;
                                                    });
                                                    try {
                                                      await jobRequestProvider.updateJobRequestStatus(
                                                        selectedJobId!,
                                                        JobRequestStatus.approved,
                                                        assigned: true,
                                                      );
                                                      await salespersonProvider.updateSalespersonStatus(
                                                        selectedSalespersonId!,
                                                        model.SalespersonStatus.busy,
                                                      );
                                                      setState(() {
                                                        assignMessage = 'Job assigned successfully!';
                                                        selectedJobId = null;
                                                        selectedSalespersonId = null;
                                                      });
                                                    } catch (e) {
                                                      setState(() {
                                                        assignMessage = 'Failed to assign: ${e.toString()}';
                                                      });
                                                    } finally {
                                                      setState(() {
                                                        isAssigning = false;
                                                      });
                                                    }
                                                  }
                                                : null,
                                            child: isAssigning
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                  )
                                                : const Text(
                                                    'Assign',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (assignMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 56, top: 16),
                                    child: Text(
                                      assignMessage!,
                                      style: TextStyle(
                                        color: assignMessage!.contains('success') ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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

class _JobListItem extends StatelessWidget {
  final JobRequest job;
  final bool selected;
  final VoidCallback onTap;
  const _JobListItem({required this.job, required this.selected, required this.onTap, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.grey.shade200, child: Icon(Icons.assignment, color: Colors.grey), radius: 18),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(job.subtitle ?? '',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
              ],
            ),
            const Spacer(),
            Text(job.id,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(width: 32),
            Text(job.time ?? '',
                style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B))),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(Icons.check_circle, color: Color(0xFF36A1C5)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SalespersonDropdown extends StatelessWidget {
  final List<model.Salesperson> salesPeople;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _SalespersonDropdown({required this.salesPeople, required this.selectedId, required this.onChanged, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedId,
      items: salesPeople
          .map((sp) => DropdownMenuItem(value: sp.id, child: Text(sp.name)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SalespersonItem extends StatelessWidget {
  final String name;
  const _SalespersonItem({required this.name, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(name, style: TextStyle(fontSize: 13, color: Color(0xFF1B2330))),
      ),
    );
  }
}
