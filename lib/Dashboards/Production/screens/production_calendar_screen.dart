import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../models/production_job.dart';
import '../providers/production_job_provider.dart';

class ProductionCalendarScreen extends StatefulWidget {
  const ProductionCalendarScreen({Key? key}) : super(key: key);

  @override
  State<ProductionCalendarScreen> createState() => _ProductionCalendarScreenState();
}

class _ProductionCalendarScreenState extends State<ProductionCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<ProductionJob>> _groupedJobs = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductionJobProvider>(context, listen: false).fetchProductionJobs();
    });
  }

  void _groupJobsByDate(List<ProductionJob> jobs) {
    _groupedJobs.clear();
    for (final job in jobs) {
      final date = DateTime(job.dueDate.year, job.dueDate.month, job.dueDate.day);
      if (_groupedJobs[date] == null) {
        _groupedJobs[date] = [];
      }
      _groupedJobs[date]!.add(job);
    }
  }

  List<ProductionJob> _getJobsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _groupedJobs[normalizedDay] ?? [];
  }

  void _showJobsForDay(BuildContext context, DateTime day, List<ProductionJob> jobs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Jobs for ${day.day}/${day.month}/${day.year}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF232B3E),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          // Set a max height to avoid overflow
          height: MediaQuery.of(context).size.height * 0.6,
          child: jobs.isEmpty
              ? const Text('No jobs scheduled for this day.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...jobs.map((job) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getStatusColor(job.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(job.status).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Job #${job.jobNo}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF232B3E),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(job.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        job.status.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Client: ${job.clientName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${job.description}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due Date: ${job.dueDate.day}/${job.dueDate.month}/${job.dueDate.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.received:
        return Colors.blue;
      case JobStatus.assignedLabour:
        return Colors.orange;
      case JobStatus.inProgress:
      case JobStatus.processedForPrinting:
        return Colors.purple;
      case JobStatus.printingCompleted:
        return Colors.teal;
      case JobStatus.completed:
        return Colors.green;      case JobStatus.onHold:
        return Colors.red;
      case JobStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Row(
        children: [
          ProductionSidebar(
            selectedIndex: 4,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/production/dashboard');
              } else if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/production/assignlabour');
              } else if (index == 2) {
                Navigator.of(context).pushReplacementNamed('/production/joblist');
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed(
                  '/production/reimbursement_request',
                  arguments: {'employeeId': 'prod1001'},
                );
              } else if (index == 4) {
                // Already on Calendar
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                const ProductionTopBar(),
                Expanded(
                  child: Consumer<ProductionJobProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Text(
                            'Error: ${provider.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      _groupJobsByDate(provider.jobs);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Production Calendar',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF232B3E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Track production jobs by due date',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TableCalendar<ProductionJob>(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                calendarFormat: _calendarFormat,
                                eventLoader: _getJobsForDay,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                calendarStyle: const CalendarStyle(
                                  outsideDaysVisible: false,
                                  selectedDecoration: BoxDecoration(
                                    color: Color(0xFF8B5FBF),
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Color(0xFFB794F6),
                                    shape: BoxShape.circle,
                                  ),
                                  markerDecoration: BoxDecoration(
                                    color: Color(0xFF8B5FBF),
                                    shape: BoxShape.circle,
                                  ),
                                  markersMaxCount: 3,
                                ),
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                  formatButtonShowsNext: false,
                                  formatButtonDecoration: BoxDecoration(
                                    color: Color(0xFF8B5FBF),
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                  formatButtonTextStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  
                                  final jobs = _getJobsForDay(selectedDay);
                                  _showJobsForDay(context, selectedDay, jobs);
                                },
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                },
                                onPageChanged: (focusedDay) {
                                  setState(() {
                                    _focusedDay = focusedDay;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Job Status Legend',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF232B3E),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: [
                                      _buildLegendItem('Received', Colors.blue),
                                      _buildLegendItem('Assigned Labour', Colors.orange),
                                      _buildLegendItem('In Progress', Colors.purple),
                                      _buildLegendItem('Printing Completed', Colors.teal),
                                      _buildLegendItem('Completed', Colors.green),
                                      _buildLegendItem('On Hold', Colors.red),
                                      _buildLegendItem('Pending', Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}