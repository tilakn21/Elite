import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../services/receptionist_service.dart';
import '../models/job_request.dart';

class ReceptionistCalendarScreen extends StatefulWidget {
  final String? receptionistId;
  const ReceptionistCalendarScreen({Key? key, this.receptionistId}) : super(key: key);

  @override
  State<ReceptionistCalendarScreen> createState() => _ReceptionistCalendarScreenState();
}

class _ReceptionistCalendarScreenState extends State<ReceptionistCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<JobRequest>> _jobRequestsFuture;
  final ReceptionistService _receptionistService = ReceptionistService();
  Map<DateTime, List<JobRequest>> _jobRequestsMap = {};

  String _receptionistName = '';
  String _branchName = '';
  String _receptionistId = ''; // Will be set from widget parameter

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Set receptionistId from widget parameter or use empty string if null
    _receptionistId = widget.receptionistId ?? '';
    print('[CALENDAR] Using receptionist ID: $_receptionistId');
    
    _selectedDay = DateTime.now();
    _loadJobRequests();
    _fetchReceptionistAndBranch();
  }

  void _loadJobRequests() {
    _jobRequestsFuture = _receptionistService.fetchJobRequestsFromSupabase();
    _jobRequestsFuture.then((jobRequests) {
      setState(() {
        _jobRequestsMap = _groupJobRequestsByDate(jobRequests);
      });
    });
  }

  Future<void> _fetchReceptionistAndBranch() async {
    if (_receptionistId.isEmpty) {
      print('[CALENDAR] Warning: Receptionist ID is empty');
      setState(() {
        _receptionistName = 'Unknown';
        _branchName = 'Unknown';
      });
      return;
    }
    
    try {
      final details = await _receptionistService.fetchReceptionistDetails(receptionistId: _receptionistId);
      String name = details?['full_name'] ?? '';
      String branchName = '';
      
      if (details != null && details['branch_id'] != null) {
        branchName = await _receptionistService.fetchBranchName(int.parse(details['branch_id'].toString())) ?? '';
      }
      
      setState(() {
        _receptionistName = name;
        _branchName = branchName;
      });
      print('[CALENDAR] Fetched details: name=$_receptionistName, branch=$_branchName');
    } catch (e) {
      print('[CALENDAR] Error fetching receptionist details: $e');
      setState(() {
        _receptionistName = 'Error';
        _branchName = 'Error';
      });
    }
  }

  Map<DateTime, List<JobRequest>> _groupJobRequestsByDate(List<JobRequest> jobRequests) {
    Map<DateTime, List<JobRequest>> data = {};
    for (var jobRequest in jobRequests) {
      if (jobRequest.dateAdded != null) {
        try {
          DateTime date = jobRequest.dateAdded!;
          DateTime dateKey = DateTime(date.year, date.month, date.day);
          if (data[dateKey] != null) {
            data[dateKey]!.add(jobRequest);
          } else {
            data[dateKey] = [jobRequest];
          }
        } catch (e) {
          // Skip invalid dates
          continue;
        }
      }
    }
    return data;
  }

  List<JobRequest> _getJobRequestsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return _jobRequestsMap[dateKey] ?? [];
  }

  void _showJobRequestsDialog(DateTime selectedDay) {
    List<JobRequest> jobRequests = _getJobRequestsForDay(selectedDay);
    
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
                  color: Color(0xFF112233),
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
                child: jobRequests.isEmpty
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
                              'No job requests for this day',
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
                        itemCount: jobRequests.length,
                        itemBuilder: (context, index) {
                          final jobRequest = jobRequests[index];
                          return _buildJobRequestCard(jobRequest);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobRequestCard(JobRequest jobRequest) {
    Color statusColor = _getStatusColor(jobRequest.status);
    IconData statusIcon = _getStatusIcon(jobRequest.status);

    final String shortId = jobRequest.id.length > 8 ? jobRequest.id.substring(0, 8) : jobRequest.id;

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
                    color: const Color(0xFF112233),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: $shortId',
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
                        _getStatusText(jobRequest.status),
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
              jobRequest.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232B3E),
              ),
            ),
            if (jobRequest.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                jobRequest.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  jobRequest.phone,
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
                    jobRequest.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (jobRequest.time != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    jobRequest.time!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
                _buildJobDetailChip('Assigned', jobRequest.assigned ?? false),
                const SizedBox(width: 8),
                _buildJobDetailChip('Has Avatar', jobRequest.avatar?.isNotEmpty ?? false),
                const SizedBox(width: 8),
                _buildJobDetailChip('Reception Data', jobRequest.receptionistJson != null),
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

  Color _getStatusColor(JobRequestStatus status) {
    switch (status) {
      case JobRequestStatus.approved:
        return Colors.green;
      case JobRequestStatus.pending:
        return Colors.orange;
      case JobRequestStatus.declined:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(JobRequestStatus status) {
    switch (status) {
      case JobRequestStatus.approved:
        return Icons.check_circle;
      case JobRequestStatus.pending:
        return Icons.access_time;
      case JobRequestStatus.declined:
        return Icons.cancel;
    }
  }

  String _getStatusText(JobRequestStatus status) {
    switch (status) {
      case JobRequestStatus.approved:
        return 'Approved';
      case JobRequestStatus.pending:
        return 'Pending';
      case JobRequestStatus.declined:
        return 'Declined';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F5FF),
      body: Row(
        children: [
          if (!isMobile) Sidebar(selectedIndex: 4, employeeId: _receptionistId),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reception Calendar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Color(0xFF232B3E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click on any date to view job requests for that day',
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
                            child: TableCalendar<JobRequest>(
                              key: ValueKey(_jobRequestsMap.hashCode),
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              eventLoader: _getJobRequestsForDay,
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
                                _showJobRequestsDialog(selectedDay);
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
                                  color: const Color(0xFF112233).withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: Color(0xFF112233),
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: Colors.teal[600],
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
                                  color: Color(0xFF112233),
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                formatButtonTextStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left,
                                  color: Color(0xFF112233),
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF112233),
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
                                          color: Colors.teal[600],
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
    );
  }
}