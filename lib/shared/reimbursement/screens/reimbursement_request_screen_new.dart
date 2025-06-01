import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../index.dart';
import '../../../Dashboards/Design/widgets/sidebar.dart' as design;
import '../../../Dashboards/Design/widgets/design_top_bar.dart';
import 'package:elite_signboard_app/Dashboards/Production/widgets/sidebar.dart';
import 'package:elite_signboard_app/Dashboards/Production/widgets/top_bar.dart';

class ReimbursementRequestScreenNew extends StatefulWidget {
  final String dashboardType;

  const ReimbursementRequestScreenNew({Key? key, required this.dashboardType}) : super(key: key);

  @override
  State<ReimbursementRequestScreenNew> createState() => _ReimbursementRequestScreenNewState();
}

class _ReimbursementRequestScreenNewState extends State<ReimbursementRequestScreenNew> {
  String? _empId;
  String? _empName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    // TODO: Replace with actual authentication once implemented
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    if (!mounted) return;
    setState(() {
      _empId = 'sal2005'; // Demo employee ID
      _empName = 'John Doe'; // Demo employee name
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReimbursementProvider(ReimbursementService()),
      child: Builder(
        builder: (context) => Scaffold(
          body: Row(
            children: [
              if (widget.dashboardType == 'design')
                design.DesignSidebar(
                  selectedIndex: 2,                  onItemTapped: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushReplacementNamed(context, '/design/dashboard');
                        break;
                      case 1:
                        Navigator.pushReplacementNamed(context, '/design/jobs');
                        break;
                      case 3:
                        Navigator.pushReplacementNamed(context, '/design/chats');
                        break;
                    }
                  },
                )
              else if (widget.dashboardType == 'production')
                // Use ProductionSidebar and ProductionTopBar for production dashboard
                ...[
                  ProductionSidebar(
                    selectedIndex: 3,
                    onItemTapped: (index) {
                      switch (index) {
                        case 0:
                          Navigator.pushReplacementNamed(context, '/production/dashboard');
                          break;
                        case 1:
                          Navigator.pushReplacementNamed(context, '/production/assignlabour');
                          break;
                        case 2:
                          Navigator.pushReplacementNamed(context, '/production/joblist');
                          break;
                        case 3:
                          Navigator.pushReplacementNamed(context, '/production/reimbursement');
                          break;
                      }
                    },
                  ),
                ],
              Expanded(
                child: Column(
                  children: [
                    if (widget.dashboardType == 'design') const DesignTopBar(),
                    if (widget.dashboardType == 'production') const ProductionTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reimbursement Request',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 24),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else if (_empId != null && _empName != null)
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: ReimbursementRequestForm(
                                    empId: _empId!,
                                    empName: _empName!,
                                  ),
                                ),
                              )
                            else
                              const Center(
                                child: Text(
                                  'Could not load user information. Please refresh the page.',
                                  style: TextStyle(color: Colors.red),
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
        ),
      ),
    );
  }
}
