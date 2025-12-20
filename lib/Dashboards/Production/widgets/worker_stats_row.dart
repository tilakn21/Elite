import 'package:flutter/material.dart';
import '../providers/worker_provider.dart';
import 'package:provider/provider.dart';

class WorkerStatsRow extends StatelessWidget {
  const WorkerStatsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        if (workerProvider.errorMessage != null) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Error loading workers: ${workerProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final workers = workerProvider.workers;
        final totalWorkers = workers.length;
        final availableWorkers = workers.where((w) => w.assigned).length; // swapped logic
        final assignedJobs = workers.fold<int>(0, (sum, w) => sum + (w.numberOfJobs));

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: workerProvider.isLoading ? 0.5 : 1.0,
          child: Row(
            children: [
              _StatCard(
                title: 'Total Workers',
                value: totalWorkers.toString(),
                icon: Icons.people,
                color: const Color(0xFF57B9C6),
                subtitle: 'All registered workers',
              ),
              const SizedBox(width: 24),
              _StatCard(
                title: 'Available',
                value: availableWorkers.toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF27AE60),
                subtitle: 'Ready to be assigned',
              ),
              const SizedBox(width: 24),
              _StatCard(
                title: 'Assigned',
                value: assignedJobs.toString(),
                icon: Icons.assignment_ind,
                color: const Color(0xFFE74C3C),
                subtitle: 'Currently on jobs',
              ),
            ],
          ),
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
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      value,
                      key: ValueKey(value),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232B3E),
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
