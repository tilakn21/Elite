import 'package:flutter/material.dart';
import '../models/production_job.dart';

class DynamicProgressBar extends StatelessWidget {
  final ProductionJob? job;
  
  const DynamicProgressBar({Key? key, this.job}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return _buildEmptyProgressBar();
    }
    
    final progressData = _calculateProgress(job!);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with job info
            Row(
              children: [
                Icon(
                  Icons.engineering,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Production Progress - Job ${job!.jobNo}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      job!.clientName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildProgressPercentage(progressData),
              ],
            ),
            const SizedBox(height: 24),
            
            // Progress steps
            Row(
              children: [
                _buildProgressStep(
                  'Received',
                  Icons.inbox,
                  progressData['received']!,
                  progressData['receivedDate'],
                  isFirst: true,
                ),
                _buildProgressConnector(progressData['received']!),
                
                _buildProgressStep(
                  'Assigned',
                  Icons.person_add,
                  progressData['assignedLabour']!,
                  progressData['assignedLabourDate'],
                ),
                _buildProgressConnector(progressData['assignedLabour']!),
                
                _buildProgressStep(
                  'In Progress',
                  Icons.build,
                  progressData['inProgress']!,
                  progressData['inProgressDate'],
                ),
                _buildProgressConnector(progressData['inProgress']!),
                
                _buildProgressStep(
                  'Completed',
                  Icons.check_circle,
                  progressData['completed']!,
                  progressData['completedDate'],
                  isLast: true,
                ),
              ],
            ),
              const SizedBox(height: 16),
              // Status history summary
            if (progressData['lastUpdate'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last Updated: ${progressData['lastUpdate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildCurrentStatusChip(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusHistorySection(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentStatusChip() {
    if (job == null) return const SizedBox.shrink();
    
    Color chipColor;
    String statusText = job!.status.label;
    
    switch (job!.status) {
      case JobStatus.receiver:
        chipColor = Colors.orange;
        break;
      case JobStatus.assignedLabour:
        chipColor = Colors.blue;
        break;
      case JobStatus.inProgress:
        chipColor = Colors.purple;
        break;
      case JobStatus.completed:
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildEmptyProgressBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Text(
              'Select a job to view production progress',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressPercentage(Map<String, dynamic> progressData) {
    int completedSteps = 0;
    if (progressData['received'] == true) completedSteps++;
    if (progressData['assignedLabour'] == true) completedSteps++;
    if (progressData['inProgress'] == true) completedSteps++;
    if (progressData['completed'] == true) completedSteps++;
    
    int percentage = (completedSteps / 4 * 100).round();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: percentage == 100 ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percentage == 100 ? Icons.check : Icons.trending_up,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressStep(
    String label,
    IconData icon,
    bool isCompleted,
    String? date, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              boxShadow: isCompleted ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildProgressConnector(bool isCompleted) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
  
  Widget _buildStatusHistorySection() {
    if (job?.productionjsonb == null) return const SizedBox.shrink();
    
    final productionData = job!.productionjsonb!;
    if (!productionData.containsKey('status_history') || 
        productionData['status_history'] is! List) {
      return const SizedBox.shrink();
    }
    
    final statusHistory = productionData['status_history'] as List;
    if (statusHistory.isEmpty) return const SizedBox.shrink();
    
    return ExpansionTile(
      leading: Icon(Icons.history, color: Colors.blue.shade600, size: 20),
      title: Text(
        'Status History (${statusHistory.length} updates)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: statusHistory.reversed.take(5).map((entry) {
              if (entry is! Map<String, dynamic>) return const SizedBox.shrink();
              
              final status = entry['status'] as String? ?? 'Unknown';
              final updatedAt = entry['updated_at'] as String?;
              final feedback = entry['feedback'] as String?;
              final previousStatus = entry['previous_status'] as String?;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),                  border: Border(
                    left: BorderSide(
                      color: _getStatusColor(status),
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                        const Spacer(),
                        if (updatedAt != null)
                          Text(
                            _formatDate(updatedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    if (previousStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From: ${_getStatusLabel(previousStatus)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (feedback != null && feedback.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 14,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                feedback,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'receiver':
        return Colors.orange;
      case 'assignedlabour':
        return Colors.blue;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'receiver':
        return 'Received';
      case 'assignedlabour':
        return 'Assigned to Labour';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status.toUpperCase();
    }
  }

  Map<String, dynamic> _calculateProgress(ProductionJob job) {
    Map<String, dynamic> progress = {
      'received': false,
      'assignedLabour': false,
      'inProgress': false,
      'completed': false,
      'receivedDate': null,
      'assignedLabourDate': null,
      'inProgressDate': null,
      'completedDate': null,
      'lastUpdate': null,
    };
    
    // Check current status first
    JobStatus currentStatus = job.status;
    
    // Parse production JSONB for status history
    if (job.productionjsonb != null) {
      final productionData = job.productionjsonb!;
      
      // Get status history
      if (productionData.containsKey('status_history') && 
          productionData['status_history'] is List) {
        final statusHistory = productionData['status_history'] as List;
        
        for (var entry in statusHistory) {
          if (entry is Map<String, dynamic>) {
            final status = entry['status'] as String?;
            final updatedAt = entry['updated_at'] as String?;
            
            if (status != null && updatedAt != null) {
              final dateStr = _formatDate(updatedAt);
              
              switch (status.toLowerCase()) {
                case 'receiver':
                  progress['received'] = true;
                  progress['receivedDate'] = dateStr;
                  break;
                case 'assignedlabour':
                  progress['assignedLabour'] = true;
                  progress['assignedLabourDate'] = dateStr;
                  break;
                case 'inprogress':
                  progress['inProgress'] = true;
                  progress['inProgressDate'] = dateStr;
                  break;
                case 'completed':
                  progress['completed'] = true;
                  progress['completedDate'] = dateStr;
                  break;
              }
              
              progress['lastUpdate'] = dateStr;
            }
          }
        }
      }
      
      // If no history, check current status from JSONB
      if (productionData.containsKey('current_status')) {
        final currentStatusStr = productionData['current_status'] as String?;
        if (currentStatusStr != null) {
          _setProgressFromStatus(progress, currentStatusStr);
        }
      }
    }
    
    // Fallback to main job status if no JSONB data
    if (!progress['received'] && !progress['assignedLabour'] && 
        !progress['inProgress'] && !progress['completed']) {
      _setProgressFromStatus(progress, _getStatusString(currentStatus));
    }
    
    return progress;
  }
    void _setProgressFromStatus(Map<String, dynamic> progress, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        progress['received'] = true;
        progress['assignedLabour'] = true;
        progress['inProgress'] = true;
        progress['completed'] = true;
        break;
      case 'inprogress':
        progress['received'] = true;
        progress['assignedLabour'] = true;
        progress['inProgress'] = true;
        break;
      case 'assignedlabour':
        progress['received'] = true;
        progress['assignedLabour'] = true;
        break;
      case 'receiver':
        progress['received'] = true;
        break;
    }
  }
  
  String _getStatusString(JobStatus status) {
    switch (status) {
      case JobStatus.receiver:
        return 'receiver';
      case JobStatus.assignedLabour:
        return 'assignedlabour';
      case JobStatus.inProgress:
        return 'inprogress';
      case JobStatus.completed:
        return 'completed';
      default:
        return 'receiver';
    }
  }
  
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
