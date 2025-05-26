import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_request_provider.dart';
import '../models/job_request.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class ViewAllJobsScreen extends StatelessWidget {
  const ViewAllJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobRequestProvider = Provider.of<JobRequestProvider>(context);
    final List<JobRequest> jobRequests = jobRequestProvider.jobRequests;
    final bool isLoading = jobRequestProvider.isLoading;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  isDashboard: false,
                  showMenu: isMobile,
                  onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'New job request',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 28,
                                            color: Color(0xFF1B2330),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Today's Requests",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF7B7B7B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7DE2D1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        minimumSize: const Size(200, 54),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/receptionist/new-job-request');
                                      },
                                      child: const Text(
                                        '+Add New job',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 150,
                                  child: Builder(
                                    builder: (context) {
                                      final todaysJobs = jobRequests.where((job) {
                                        final now = DateTime.now();
                                        return job.dateAdded != null &&
                                            job.dateAdded!.year == now.year &&
                                            job.dateAdded!.month == now.month &&
                                            job.dateAdded!.day == now.day;
                                      }).toList();
                                      if (todaysJobs.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "No requests for today",
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: todaysJobs.length,
                                        itemBuilder: (context, index) {
                                          final job = todaysJobs[index];
                                          return Padding(
                                            padding: EdgeInsets.only(left: index == 0 ? 0 : 20, right: 0),
                                            child: _RequestCard(
                                              avatar: job.avatar ?? 'assets/images/elite_logo.png',
                                              name: job.name,
                                              subtitle: job.subtitle ?? '',
                                              status: job.assigned == true ? 'Assigned' : 'Unassigned',
                                              statusColor: job.assigned == true ? Color(0xFF7DE2D1) : Color(0xFFFFAFAF),
                                              date: job.dateAdded != null ? "${job.dateAdded!.day.toString().padLeft(2, '0')}/${job.dateAdded!.month.toString().padLeft(2, '0')}/${job.dateAdded!.year}" : '',
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 36),
                                _JobRequestsTable(jobRequests: jobRequests),
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

class _RequestCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String date;
  const _RequestCard({required this.avatar, required this.name, required this.subtitle, required this.status, required this.statusColor, required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(avatar),
                radius: 22,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1B2330))),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
                ],
              ),
              const Spacer(),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Assigned' ? const Color(0xFF1B2330) : const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Date', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFFBDBDBD))),
              const Spacer(),
              Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1B2330))),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobRequestsTable extends StatelessWidget {
  final List<JobRequest> jobRequests;
  const _JobRequestsTable({Key? key, required this.jobRequests}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F7FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Phone number', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('Date added', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD), fontSize: 15))),
                SizedBox(width: 28),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
          ...jobRequests.map((row) => _TableRowWidget(row)).toList(),
        ],
      ),
    );
  }
}

class _TableRowWidget extends StatelessWidget {
  final JobRequest row;
  const _TableRowWidget(this.row);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Job Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _jobDetailRow('Name', row.name),
                  _jobDetailRow('ID', row.id),
                  _jobDetailRow('Email', row.email),
                  _jobDetailRow('Phone', row.phone),
                  _jobDetailRow('Date Added', row.dateAdded != null ? " ${row.dateAdded!.day.toString().padLeft(2, '0')}/${row.dateAdded!.month.toString().padLeft(2, '0')}/${row.dateAdded!.year}" : ''),
                  _jobDetailRow('Time', row.time ?? ''),
                  _jobDetailRow('Status', row.assigned == true ? 'Assigned' : 'Unassigned'),
                  if (row.subtitle != null && row.subtitle!.isNotEmpty)
                    _jobDetailRow('Subtitle', row.subtitle!),
                  // Add more fields as needed
                ],
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage('assets/images/elite_logo.png'), radius: 18),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(row.subtitle ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: Text(row.id, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
            Expanded(child: Text(row.email, style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)))),
            Expanded(child: Text(row.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF7B7B7B)))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.dateAdded != null ? " ${row.dateAdded!.day.toString().padLeft(2, '0')}/${row.dateAdded!.month.toString().padLeft(2, '0')}/${row.dateAdded!.year}" : '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1B2330))),
                  Text(row.time ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: row.assigned == true ? const Color(0xFF7DE2D1) : const Color(0xFFFFAFAF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      row.assigned == true ? 'Assigned' : 'Unassigned',
                      style: TextStyle(
                        color: row.assigned == true ? const Color(0xFF1B2330) : const Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFBDBDBD)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _jobDetailRow(String label, String value) {
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
