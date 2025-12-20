import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../providers/worker_provider.dart';
import 'package:provider/provider.dart';

class AssignLabourCard extends StatelessWidget {
  const AssignLabourCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Production Workers',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Icon(Icons.group, color: Color(0xFF57B9C6)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<WorkerProvider>(
                builder: (context, workerProvider, child) {
                  if (workerProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (workerProvider.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Error: ${workerProvider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (workerProvider.workers.isEmpty) {
                    return const Center(child: Text('No workers available'));
                  }

                  return ListView.separated(
                    itemCount: workerProvider.workers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final worker = workerProvider.workers[index];
                      return WorkerListItem(worker: worker);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerListItem extends StatelessWidget {
  final Worker worker;

  const WorkerListItem({
    Key? key,
    required this.worker,
  }) : super(key: key);

  String _getStatusText() {
    if (worker.numberOfJobs >= 4) {
      return 'Unavailable (Max jobs reached)';
    } else if (worker.isAvailable) {
      return 'Available';
    } else {
      return 'Unavailable';
    }
  }

  Color _getStatusColor() {
    if (worker.numberOfJobs >= 4) {
      return Colors.red;
    } else if (worker.isAvailable) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/avatars/default_avatar.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(),
                  ),
                ),
                Text(
                  'Jobs assigned: ${worker.numberOfJobs}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
