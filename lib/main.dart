import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'Dashboards/Design/providers/job_provider.dart';
import 'Dashboards/Design/providers/chat_provider.dart';
import 'Dashboards/Design/providers/user_provider.dart';

// Screens
import 'Dashboards/Design/screens/dashboard_screen.dart';
import 'Dashboards/Design/screens/job_list_screen.dart';
import 'Dashboards/Design/screens/job_details_screen.dart';
import 'Dashboards/Design/screens/active_chats_screen.dart';
import 'Dashboards/Design/screens/chat_screen.dart';

// Receptionist Dashboard
import 'Dashboards/Receptionist/screens/dashboard_screen.dart';
import 'Dashboards/Receptionist/screens/new_job_request_screen.dart';
import 'Dashboards/Receptionist/screens/assign_salesperson_screen.dart';
import 'Dashboards/Receptionist/screens/view_all_jobs_screen.dart';

// Design Dashboard
import 'Dashboards/Design/screens/dashboard_screen.dart' as design;

// Salesperson Dashboard
import 'Dashboards/Salesperson/screens/home_screen.dart';
import 'Dashboards/Salesperson/screens/profile_screen.dart';

// Production Dashboard
import 'Dashboards/Production/screens/production_dashboard.dart';
import 'Dashboards/Production/screens/production_job_list_screen.dart';
import 'Dashboards/Production/screens/assign_labour_screen.dart';
import 'Dashboards/Production/screens/update_job_status_screen.dart';

// Printing Dashboard
import 'Dashboards/Printing/screens/printing_dashboard_screen.dart';
import 'Dashboards/Printing/screens/assign_labour_screen.dart';
import 'Dashboards/Printing/screens/quality_check_screen.dart';

// Utils
import 'Dashboards/Design/utils/app_theme.dart';

// Widgets
import 'Dashboards/Design/widgets/upload_draft_widget.dart';
import 'Dashboards/Design/widgets/job_details_card.dart';
import 'Dashboards/Design/widgets/active_chats_card.dart';
import 'Dashboards/Design/widgets/calendar_card.dart';

// Login Screen
import 'screens/login_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // ignore: avoid_print
    print('CAUGHT FLUTTER ERROR:');
    print(details.exceptionAsString());
    print(details.stack);
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elite Signboard Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF536DFE),
        ),
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
      //home: const SalespersonHomeScreen(),
      routes: {
        '/receptionist/dashboard': (context) => const DashboardPage(),
        '/receptionist/new-job-request': (context) => const NewJobRequestScreen(),
        '/receptionist/assign-salesperson': (context) => const AssignSalespersonScreen(),
        '/receptionist/view-all-jobs': (context) => const ViewAllJobsScreen(),
        '/salesperson/dashboard': (context) => const SalespersonHomeScreen(),
        '/salesperson/profile': (context) => const SalespersonProfileScreen(),
        '/design/dashboard': (context) => const design.DashboardScreen(),
        '/accounts/dashboard': (context) => Scaffold(body: Center(child: Text('Accounts Dashboard', style: TextStyle(fontSize: 28)))),
        '/production/dashboard': (context) => const ProductionDashboard(),
        '/production/joblist': (context) => const ProductionJobListScreen(),
        '/production/assignlabour': (context) => const AssignLabourScreen(),
        '/production/updatejobstatus': (context) => const UpdateJobStatusScreen(),
        '/printing/dashboard': (context) => const PrintingDashboardScreen(),
        '/printing/assignlabour': (context) => const PrintingAssignLabourScreen(),
        '/printing/qualitycheck': (context) => const PrintingQualityCheckScreen(),
        '/admin/dashboard': (context) => Scaffold(body: Center(child: Text('Admin Dashboard', style: TextStyle(fontSize: 28)))),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const JobListScreen(),
    const UploadDraftScreen(),
    const ActiveChatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left sidebar navigation
            Container(
              width: 188,
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'elite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  // Navigation items
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.list_alt_outlined,
                    label: 'Job details',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.upload_file_outlined,
                    label: 'Upload\nDesign Draft',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    index: 3,
                  ),
                  const Spacer(),
                  // User profile
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Text(
                              currentUser.name.substring(0, 1),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  currentUser.role,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Column(
                children: [
                  // Top app bar
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search data for this page',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.bar_chart),
                        const SizedBox(width: 16),
                        const Icon(Icons.notifications_none),
                        const SizedBox(width: 16),
                        if (currentUser != null)
                          Row(
                            children: [
                              Text(
                                currentUser.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  currentUser.name.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Screen content
                  Expanded(
                    child: _screens[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Tablet and Mobile layout
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'elite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const Spacer(),
              if (!isMobile) const Icon(Icons.bar_chart),
              if (!isMobile) const SizedBox(width: 16),
              const Icon(Icons.notifications_none),
              const SizedBox(width: 16),
              if (currentUser != null)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Text(
                    currentUser.name.substring(0, 1),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search data for this page',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.primaryColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload_file_outlined),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppTheme.accentColor, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screen for Upload Draft
class UploadDraftScreen extends StatelessWidget {
  const UploadDraftScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Design Draft',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const UploadDraftWidget(),
                    const SizedBox(height: 24),
                    Text(
                      'Upload your design drafts for client approval',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supported formats: PNG, JPG, PDF, AI, PSD',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
