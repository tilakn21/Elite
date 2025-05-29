import 'package:flutter/material.dart';
import '../providers/production_job_provider.dart';
import 'package:provider/provider.dart';
import '../models/production_job.dart';

class JobStatsRow extends StatelessWidget {
  const JobStatsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionJobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.isLoading) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }        if (jobProvider.errorMessage != null) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Error loading jobs: ${jobProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final jobs = jobProvider.jobs;
        final totalJobs = jobs.length;
        final completedJobs = jobs.where((j) => j.status == JobStatus.completed).length;
        final pendingJobs = jobs.where((j) => j.status == JobStatus.pending).length;

        return Row(
          children: [            _StatCard(
              title: 'Total Jobs',
              value: totalJobs.toString(),
              icon: Icons.work,
              color: const Color(0xFF5C6BC0),
              subtitle: 'All jobs assigned to production',
            ),
            const SizedBox(width: 24),
            _StatCard(
              title: 'Pending Jobs',
              value: pendingJobs.toString(),
              icon: Icons.pending_actions,
              color: const Color(0xFFF39C12),
              subtitle: 'Jobs waiting to start',
            ),
            const SizedBox(width: 24),
            _StatCard(
              title: 'Completed Jobs',
              value: completedJobs.toString(),
              icon: Icons.task_alt,
              color: const Color(0xFF27AE60),
              subtitle: 'Successfully finished jobs',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF232B3E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
