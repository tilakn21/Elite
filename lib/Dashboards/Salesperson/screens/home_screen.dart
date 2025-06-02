import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/salesperson_sidebar.dart';
import '../widgets/salesperson_topbar.dart';
import 'details_screen.dart';
import '../models/site_visit_item.dart';

class SalespersonHomeScreen extends StatefulWidget {
  const SalespersonHomeScreen({Key? key}) : super(key: key);

  @override
  State<SalespersonHomeScreen> createState() => _SalespersonHomeScreenState();
}

class _SalespersonHomeScreenState extends State<SalespersonHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSidebar = 'home';
  List<SiteVisitItem> visits = [];
  List<SiteVisitItem> filteredVisits = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAssignedJobs();
  }

  Future<void> _fetchAssignedJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // TODO: Replace with actual logged-in user id from auth/session
      final userId = 'sal2001';
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('jobs')
          .select()
          .filter('receptionist->>assignedSalesperson', 'eq', userId);

      visits = List<Map<String, dynamic>>.from(response)
          .map((e) {
            final receptionist = e['receptionist'] as Map<String, dynamic>?;
            final salesperson = e['salesperson'] as Map<String, dynamic>?;
            return SiteVisitItem(
              e['id']?.toString() ?? '',
              receptionist?['customerName'] ?? '',
              'assets/images/avatar1.png', // Placeholder, update if you have avatar
              receptionist?['dateOfVisit'] ?? '',
              // Determine submitted status based on salesperson.status
              (salesperson != null && (salesperson['status']?.toString().toLowerCase() == 'completed')),
              // Add extra fields for navigation
              jobJson: e,
              salespersonJson: salesperson,
              receptionistJson: receptionist,
            );
          })
          .toList();
      _applySearch();
    } catch (e) {
      _error = 'Failed to load jobs: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredVisits = List.from(visits);
      } else {
        filteredVisits = visits.where((item) {
          final name = item.name.toLowerCase();
          final siteId = item.siteId.toLowerCase();
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || siteId.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final GlobalKey<ScaffoldState> scaffoldKey = _scaffoldKey;
    Widget sidebar = SalespersonSidebar(
      selectedRoute: _selectedSidebar,
      onItemSelected: (route) {
        setState(() {
          _selectedSidebar = route;
        });
        if (route == 'profile') {
          Navigator.of(context).pushReplacementNamed('/salesperson/profile');
        } else if (route == 'home') {
          Navigator.of(context).pushReplacementNamed('/salesperson/dashboard');
        } else if (route == 'reimbursement') {
          Navigator.of(context).pushReplacementNamed('/salesperson/reimbursement');
        }
      },
    );
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile
          ? Drawer(
              width: MediaQuery.of(context).size.width * 0.75,
              child: sidebar,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(width: 240, child: sidebar),
          Expanded(
            child: Column(
              children: [
                SalespersonTopBar(
                  isDashboard: true,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by customer name or site ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F3FB),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applySearch();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                            : filteredVisits.isEmpty
                                ? Center(child: Text('No assigned jobs found.', style: TextStyle(color: Colors.grey)))
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: filteredVisits.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final item = filteredVisits[index];
                                            final salespersonJson = item.salespersonJson;
                                            final receptionistJson = item.receptionistJson ?? {};
                                            final canOpenDetails = salespersonJson == null;
                                            return GestureDetector(
                                              onTap: canOpenDetails
                                                  ? () {
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => SalespersonDetailsScreen(
                                                            jobId: item.siteId,
                                                            date: receptionistJson['dateOfAppointment'] ?? '',
                                                            customer: receptionistJson['customerName'] ?? '',
                                                            shopName: receptionistJson['shopName'] ?? '',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              child: Opacity(
                                                opacity: canOpenDetails ? 1.0 : 0.5,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.06),
                                                        blurRadius: 12,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                          backgroundImage: AssetImage(item.avatarPath),
                                                          radius: 22),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              item.name,
                                                              style: const TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15,
                                                                  color: Colors.black87),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Site ID: ',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.grey.shade700),
                                                                ),
                                                                Flexible(
                                                                  child: Text(
                                                                    item.siteId,
                                                                    style: const TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: Color(0xFF5A6CEA)),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 16),
                                                                Text(
                                                                  item.date,
                                                                  style: const TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.black54),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          color: item.submitted
                                                              ? const Color(0xFFD2F6E7)
                                                              : const Color(0xFFFFE3E3),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          item.submitted ? 'Submitted' : 'Pending',
                                                          style: TextStyle(
                                                            color: item.submitted
                                                                ? const Color(0xFF3BB77E)
                                                                : const Color(0xFFD32F2F),
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFF3F3FB),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(Icons.arrow_forward_ios, size: 22, color: Color(0xFFBDBDBD)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
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
