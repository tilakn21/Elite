import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/job_request.dart';
import '../models/salesperson.dart' as model;
import '../providers/job_request_provider.dart';
import '../providers/salesperson_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

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

  final TextEditingController _searchController = TextEditingController();
  Set<model.SalespersonStatus> _selectedStatuses = {};
  Set<String> _selectedExpertiseAreas = {};
  List<String> _allExpertiseOptions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initial fetch or listen to provider for salespersons to update expertise options
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateExpertiseOptions();
      _applyFiltersAndSearch(); // Initial load of filtered salespersons
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If salespersons list in provider changes, update expertise options
    // This might be better handled by listening to the provider if it signals data changes effectively
    _updateExpertiseOptions();
  }

  void _updateExpertiseOptions() {
    final salespersonProvider = Provider.of<SalespersonProvider>(context, listen: false);
    if (salespersonProvider.salespersons.isNotEmpty) {
      final allExpertise = salespersonProvider.salespersons
          .expand((sp) => sp.expertise)
          .toSet()
          .toList();
      allExpertise.sort();
      if (mounted && !listEquals(_allExpertiseOptions, allExpertise)) {
        setState(() {
          _allExpertiseOptions = allExpertise;
        });
      }
    }
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    final salespersonProvider = Provider.of<SalespersonProvider>(context, listen: false);
    salespersonProvider.searchAndFilterSalespersons(
      searchTerm: _searchController.text,
      selectedStatuses: _selectedStatuses.toList(),
      selectedExpertise: _selectedExpertiseAreas.toList(),
    );
    if (mounted) setState(() {}); // To rebuild with new filtered list
  }

  Future<void> _refreshSalespersons() async {
    final salespersonProvider = Provider.of<SalespersonProvider>(context, listen: false);
    await salespersonProvider.fetchSalespersons();
    _updateExpertiseOptions();
    _applyFiltersAndSearch(); // Re-apply filters after refresh
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 420;
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final salespersonProvider = Provider.of<SalespersonProvider>(context);
    final jobs = jobRequestProvider.jobRequests.where((job) => job.assigned != true).toList();
    // Use filteredSalespersons from the provider
    final salesPeople = salespersonProvider.filteredSalespersons;
    final bool isLoadingOverall = jobRequestProvider.isLoading || salespersonProvider.isLoading;

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
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Sidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: isLoadingOverall && salesPeople.isEmpty // Show loader if loading and no data yet
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 56, top: 8, right: 56),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Assign salesperson',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                          color: Color(0xFF1B2330),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                                        tooltip: 'Refresh salespersons',
                                        onPressed: _refreshSalespersons,
                                      ),
                                    ],
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
                                          const Text('Job list', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF7B7B7B))),
                                          const SizedBox(height: 16),
                                          if (jobRequestProvider.isLoading && jobs.isEmpty)
                                            const Center(child: CircularProgressIndicator())
                                          else if (jobs.isEmpty)
                                            const Text('No unassigned jobs.', style: TextStyle(color: Colors.red))
                                          else
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: jobs.length,
                                              itemBuilder: (context, index) {
                                                final job = jobs[index];
                                                return _JobListItem(
                                                  job: job,
                                                  selected: selectedJobId == job.id,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedJobId = job.id;
                                                      assignMessage = null;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    // Salesperson search and filter card
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
                                          const Text('Find Salesperson',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xFF7B7B7B))),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              hintText: 'Search by name, expertise, skill...',
                                              prefixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Colors.grey.shade300),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                                          Wrap(
                                            spacing: 8.0,
                                            children: model.SalespersonStatus.values
                                              .where((s) => s != model.SalespersonStatus.away) // Exclude 'away' for now or make it configurable
                                              .map((status) {
                                                return FilterChip(
                                                  label: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                                                  selected: _selectedStatuses.contains(status),
                                                  onSelected: (selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        _selectedStatuses.add(status);
                                                      } else {
                                                        _selectedStatuses.remove(status);
                                                      }
                                                      _applyFiltersAndSearch();
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                          ),
                                          if (_allExpertiseOptions.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Text('Expertise Area:', style: TextStyle(fontWeight: FontWeight.w500)),
                                            Wrap(
                                              spacing: 8.0,
                                              children: _allExpertiseOptions.map((expertise) {
                                                return FilterChip(
                                                  label: Text(expertise),
                                                  selected: _selectedExpertiseAreas.contains(expertise),
                                                  onSelected: (selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        _selectedExpertiseAreas.add(expertise);
                                                      } else {
                                                        _selectedExpertiseAreas.remove(expertise);
                                                      }
                                                      _applyFiltersAndSearch();
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                          const SizedBox(height: 16),
                                          if (salespersonProvider.isLoading && salesPeople.isEmpty)
                                            const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                                          else if (salesPeople.isEmpty && _searchController.text.isNotEmpty)
                                            const Text('No salespeople match your search/filters.')
                                          else if (salesPeople.isEmpty)
                                            const Text('No salespeople available or found.')
                                          else
                                            SizedBox(
                                              height: 300, // Constrain height for scrollable list
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: salesPeople.length,
                                                itemBuilder: (context, index) {
                                                  final salesperson = salesPeople[index];
                                                  return _SalespersonListItemCard(
                                                    salesperson: salesperson,
                                                    isSelected: selectedSalespersonId == salesperson.id,
                                                    onTap: () {
                                                      setState(() {
                                                        selectedSalespersonId = salesperson.id;
                                                        assignMessage = null;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 48),
                                Padding(
                                  padding: const EdgeInsets.only(left: 56, right: 56),
                                  child: Container(
                                    width: double.infinity, // Make it responsive
                                    constraints: BoxConstraints(maxWidth: cardWidth * 2 + 40),
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
                                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B2330), fontSize: 16),
                                              children: [
                                                TextSpan(
                                                    text: selectedJobId != null ? '#${jobRequestProvider.jobRequests.firstWhere((j) => j.id == selectedJobId, orElse: () => JobRequest(id: '', name: '', phone: '', email: '', status: JobRequestStatus.pending)).name}' : 'Select a job',
                                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF36A1C5))),
                                                const TextSpan(text: ' to '),
                                                TextSpan(
                                                    text: selectedSalespersonId != null ? salespersonProvider.salespersons.firstWhere((sp) => sp.id == selectedSalespersonId, orElse: () => model.Salesperson(id: '', name: 'N/A', status: model.SalespersonStatus.away, department: 'N/A')).name : 'Select a salesperson',
                                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF36A1C5))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        ElevatedButton(
                                          onPressed: (selectedJobId != null && selectedSalespersonId != null && !isAssigning)
                                              ? () async {
                                                  setState(() { isAssigning = true; assignMessage = null; });
                                                  try {
                                                    await jobRequestProvider.updateJobRequestStatus(
                                                      selectedJobId!,
                                                      JobRequestStatus.approved, // Set status to approved
                                                      assigned: true,
                                                      salespersonId: selectedSalespersonId!,
                                                    );
                                                    // Optionally update salesperson status locally or refetch
                                                    final spToUpdate = salespersonProvider.salespersons.firstWhere((sp) => sp.id == selectedSalespersonId);
                                                    await salespersonProvider.updateSalespersonStatus(selectedSalespersonId!, model.SalespersonStatus.busy); // Or onVisit
                                                    
                                                    setState(() {
                                                      assignMessage = 'Successfully assigned job to ${spToUpdate.name}.';
                                                      selectedJobId = null;
                                                      selectedSalespersonId = null;
                                                      _searchController.clear(); // Clear search
                                                      _selectedStatuses.clear();
                                                      _selectedExpertiseAreas.clear();
                                                      _applyFiltersAndSearch(); // Refresh list
                                                    });
                                                  } catch (e) {
                                                    setState(() { assignMessage = 'Error assigning job: $e'; });
                                                  }
                                                  setState(() { isAssigning = false; });
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF5A39E8),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: isAssigning
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (assignMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 56, top: 16, right: 56),
                                    child: Text(
                                      assignMessage!,
                                      style: TextStyle(color: assignMessage!.startsWith('Error') ? Colors.red : Colors.green, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                const SizedBox(height: 40),
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

// Helper function to compare lists (needed for _updateExpertiseOptions)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _JobListItem extends StatelessWidget {
  final JobRequest job;
  final bool selected;
  final VoidCallback onTap;

  const _JobListItem({
    Key? key,
    required this.job,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8E1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFF5A39E8) : const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: job.avatar != null && job.avatar!.isNotEmpty ? AssetImage(job.avatar!) : null,
              child: job.avatar == null || job.avatar!.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(job.subtitle ?? 'No details', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text(job.time ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// New Salesperson List Item Card
class _SalespersonListItemCard extends StatelessWidget {
  final model.Salesperson salesperson;
  final bool isSelected;
  final VoidCallback onTap;

  const _SalespersonListItemCard({
    Key? key,
    required this.salesperson,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: salesperson.avatar != null && salesperson.avatar!.isNotEmpty ? AssetImage(salesperson.avatar!) : null,
                child: salesperson.avatar == null || salesperson.avatar!.isEmpty ? Text(salesperson.name[0]) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(salesperson.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(salesperson.department, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    if (salesperson.expertise.isNotEmpty)
                      Text('Expertise: ${salesperson.expertise.join(', ')}', style: const TextStyle(fontSize: 12)),
                    Text('Status: ${salesperson.status.name}', style: TextStyle(fontSize: 12, color: _getStatusColor(salesperson.status))),
                    Text('Workload: ${salesperson.currentWorkload}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(model.SalespersonStatus status) {
    switch (status) {
      case model.SalespersonStatus.available:
        return Colors.green;
      case model.SalespersonStatus.busy:
        return Colors.orange;
      case model.SalespersonStatus.onVisit:
        return Colors.blue;
      case model.SalespersonStatus.away:
        return Colors.grey;
    }
  }
}
