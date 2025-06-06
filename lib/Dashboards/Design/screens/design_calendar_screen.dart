import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/sidebar.dart';
import '../widgets/design_top_bar.dart';
import '../services/design_service.dart';
import '../models/job.dart';

class DesignCalendarScreen extends StatefulWidget {
  const DesignCalendarScreen({Key? key}) : super(key: key);

  @override
  State<DesignCalendarScreen> createState() => _DesignCalendarScreenState();
}

class _DesignCalendarScreenState extends State<DesignCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<Job>> _jobsFuture;
  final DesignService _designService = DesignService();
  Map<DateTime, List<Job>> _jobsMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadJobs();
  }

  void _loadJobs() {
    _jobsFuture = _designService.getJobs();
    _jobsFuture.then((jobs) {
      setState(() {
        _jobsMap = _groupJobsByDate(jobs);
      });
    });
  }

  Map<DateTime, List<Job>> _groupJobsByDate(List<Job> jobs) {
    Map<DateTime, List<Job>> data = {};
    for (var job in jobs) {
      try {
        DateTime date = job.dateAdded;
        DateTime dateKey = DateTime(date.year, date.month, date.day);
        if (data[dateKey] != null) {
          data[dateKey]!.add(job);
        } else {
          data[dateKey] = [job];
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }
    return data;
  }

  List<Job> _getJobsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return _jobsMap[dateKey] ?? [];
  }

  void _showJobsDialog(DateTime selectedDay) {
    List<Job> jobs = _getJobsForDay(selectedDay);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF101C2C),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: jobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs scheduled for this day',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return _buildJobCard(job);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    Color statusColor = _getStatusColor(job.status);
    IconData statusIcon = _getStatusIcon(job.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101C2C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Job #${job.jobNo}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(job.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.clientName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232B3E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  job.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    job.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (job.assignedTo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Assigned to: ${job.assignedTo}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildJobDetailChip('Measurements', job.measurements?.isNotEmpty ?? false),
                const SizedBox(width: 8),
                _buildJobDetailChip('Images', job.uploadedImages?.isNotEmpty ?? false),
                const SizedBox(width: 8),
                _buildJobDetailChip('Design Ready', job.design != null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailChip(String label, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: isCompleted ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return Colors.green;
      case JobStatus.inProgress:
        return Colors.blue;
      case JobStatus.pending:
        return Colors.orange;
    }
  }
  IconData _getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return Icons.check_circle;
      case JobStatus.inProgress:
        return Icons.autorenew;
      case JobStatus.pending:
        return Icons.access_time;
    }
  }
  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return 'Approved';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesignSidebar(
              selectedIndex: 4,
              onItemTapped: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/design/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/design/joblist');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/design/reimbursement_request');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/design/chats');
                }
                // index 4 (Calendar) - stay on current page
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const DesignTopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Design Calendar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Color(0xFF232B3E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click on any date to view scheduled design jobs',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: TableCalendar<Job>(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                eventLoader: _getJobsForDay,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  if (!isSameDay(_selectedDay, selectedDay)) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  }
                                  _showJobsDialog(selectedDay);
                                },
                                onFormatChanged: (format) {
                                  if (_calendarFormat != format) {
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                },
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF101C2C).withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF101C2C),
                                    shape: BoxShape.circle,
                                  ),
                                  markerDecoration: BoxDecoration(
                                    color: Colors.deepPurple[600],
                                    shape: BoxShape.circle,
                                  ),
                                  markersMaxCount: 3,
                                  markersAnchor: 0.7,
                                  weekendTextStyle: TextStyle(
                                    color: Colors.red[400],
                                  ),
                                  holidayTextStyle: TextStyle(
                                    color: Colors.red[400],
                                  ),
                                ),
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                  formatButtonShowsNext: false,
                                  formatButtonDecoration: BoxDecoration(
                                    color: Color(0xFF101C2C),
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                  formatButtonTextStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: Color(0xFF101C2C),
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF101C2C),
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (events.isNotEmpty) {
                                      return Positioned(
                                        right: 1,
                                        bottom: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple[600],
                                            shape: BoxShape.circle,
                                          ),
                                          width: 16,
                                          height: 16,
                                          child: Center(
                                            child: Text(
                                              '${events.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
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
      ),
    );
  }
}