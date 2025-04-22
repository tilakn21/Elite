import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../models/job.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../widgets/upload_draft_widget.dart';
import 'chat_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  
  const JobDetailsScreen({
    Key? key, 
    required this.jobId,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _notesController = TextEditingController();
  final _commentsController = TextEditingController();
  final _measurementsController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  Job? _job;
  Chat? _activeChat;
  bool _isEditingDetails = false;
  bool _showChatPanel = false;
  List<String> _uploadedImages = [];
  
  // Status tracking
  double _progressValue = 0.0;
  String _progressStatus = 'Not Started';
  String _estimatedCompletion = 'N/A';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobDetails();
      _loadActiveChat();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _commentsController.dispose();
    _measurementsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadJobDetails() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final job = jobProvider.getJobById(widget.jobId);
    
    if (job != null) {
      setState(() {
        _job = job;
        if (job.notes != null) {
          _notesController.text = job.notes!;
        }
        if (job.address != null) {
          _addressController.text = job.address;
        }
        if (job.phoneNumber != null) {
          _phoneController.text = job.phoneNumber;
        }
        if (job.measurements != null) {
          _measurementsController.text = job.measurements!;
        }
        
        // Set progress based on status
        switch (job.status) {
          case JobStatus.inProgress:
            _progressValue = 0.3;
            _progressStatus = 'In Progress';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now().add(const Duration(days: 14))
            );
            break;
          case JobStatus.pending:
            _progressValue = 0.7;
            _progressStatus = 'Pending Approval';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now().add(const Duration(days: 7))
            );
            break;
          case JobStatus.approved:
            _progressValue = 1.0;
            _progressStatus = 'Completed';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now().subtract(const Duration(days: 2))
            );
            break;
        }
      });
    }
  }
  
  void _loadActiveChat() {
    if (_job == null) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chat = chatProvider.getChatByCustomerId(_job!.id);
    
    if (chat != null) {
      setState(() {
        _activeChat = chat;
      });
    }
  }

  void _updateJobStatus(JobStatus status) {
    if (_job != null) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final updatedJob = _job!.copyWith(
        status: status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        measurements: _measurementsController.text.isEmpty ? null : _measurementsController.text,
      );
      
      jobProvider.updateJob(updatedJob);
      setState(() {
        _job = updatedJob;
        
        // Update progress based on new status
        switch (status) {
          case JobStatus.inProgress:
            _progressValue = 0.3;
            _progressStatus = 'In Progress';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now().add(const Duration(days: 14))
            );
            break;
          case JobStatus.pending:
            _progressValue = 0.7;
            _progressStatus = 'Pending Approval';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now().add(const Duration(days: 7))
            );
            break;
          case JobStatus.approved:
            _progressValue = 1.0;
            _progressStatus = 'Completed';
            _estimatedCompletion = DateFormat('dd/MM/yyyy').format(
              DateTime.now()
            );
            break;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job status updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _submitForApproval() {
    _updateJobStatus(JobStatus.pending);
  }
  
  void _approveJob() {
    _updateJobStatus(JobStatus.approved);
  }
  
  void _setInProgress() {
    _updateJobStatus(JobStatus.inProgress);
  }

  void _toggleChatPanel() {
    setState(() {
      _showChatPanel = !_showChatPanel;
    });
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditingDetails = !_isEditingDetails;
    });
  }

  void _openChatWithCustomer() {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    
    if (_job != null) {
      if (isDesktop) {
        // On desktop, toggle the side panel
        _toggleChatPanel();
      } else {
        // On mobile, navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              customerId: _job!.id,
              customerName: _job!.clientName,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_job == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Job #${_job!.jobNo}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isDesktop || !_showChatPanel)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _openChatWithCustomer,
              tooltip: 'Chat with customer',
            ),
          IconButton(
            icon: Icon(_isEditingDetails ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditingDetails ? 'Save changes' : 'Edit details',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'approve':
                  _approveJob();
                  break;
                case 'pending':
                  _submitForApproval();
                  break;
                case 'progress':
                  _setInProgress();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'approve',
                child: Text('Mark as Approved'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Mark as Pending'),
              ),
              const PopupMenuItem(
                value: 'progress',
                child: Text('Mark as In Progress'),
              ),
            ],
          ),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout()
          : isTablet
              ? _buildTabletLayout()
              : _buildMobileLayout(),
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area
        Expanded(
          flex: _showChatPanel ? 2 : 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerInformation(),
                          const SizedBox(height: 24),
                          _buildSalespersonInformation(),
                          const SizedBox(height: 24),
                          _buildSiteVisitData(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobProgress(),
                          const SizedBox(height: 24),
                          _buildUploadDraftDesign(),
                          const SizedBox(height: 24),
                          _buildComments(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _submitForApproval,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Submit for Approval'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Chat panel (only shown when _showChatPanel is true)
        if (_showChatPanel)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(16),
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
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          _job!.clientName.substring(0, 1),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _job!.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _job!.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleChatPanel,
                      ),
                    ],
                  ),
                ),
                
                // Chat messages
                Expanded(
                  child: _activeChat != null && _activeChat!.messages.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activeChat!.messages.length,
                          itemBuilder: (context, index) {
                            final message = _activeChat!.messages[index];
                            final isAdmin = message.senderId == 'admin';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: isAdmin 
                                    ? MainAxisAlignment.end 
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isAdmin) ...[  
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[200],
                                      child: Text(
                                        _job!.clientName.substring(0, 1),
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 250,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin 
                                          ? AppTheme.accentColor 
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.message,
                                          style: TextStyle(
                                            color: isAdmin 
                                                ? Colors.white 
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('h:mm a').format(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isAdmin 
                                                ? Colors.white.withOpacity(0.7) 
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (isAdmin) ...[  
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.accentColor,
                                      child: const Text(
                                        'A',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                ),
                
                // Message input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.accentColor,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 24),
          _buildJobProgress(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInformation(),
                    const SizedBox(height: 24),
                    _buildSalespersonInformation(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSiteVisitData(),
                    const SizedBox(height: 24),
                    _buildUploadDraftDesign(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildComments(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForApproval,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Submit for Approval'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 16),
          _buildJobProgress(),
          const SizedBox(height: 16),
          _buildCustomerInformation(),
          const SizedBox(height: 16),
          _buildSalespersonInformation(),
          const SizedBox(height: 16),
          _buildSiteVisitData(),
          const SizedBox(height: 16),
          _buildUploadDraftDesign(),
          const SizedBox(height: 16),
          _buildComments(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForApproval,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Submit for Approval'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Job Details',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_job!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(_job!.status),
                style: TextStyle(
                  color: _getStatusColor(_job!.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Created on ${DateFormat('dd MMM yyyy').format(_job!.dateAdded)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildJobProgress() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey[200],
              color: AppTheme.accentColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressItem('Status', _progressStatus),
                _buildProgressItem('Estimated Completion', _estimatedCompletion),
                _buildProgressItem('Job Number', _job!.jobNo),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildCustomerInformation() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Client Name', _job!.clientName),
            const SizedBox(height: 12),
            _buildInfoRow('Phone no.', _job!.phoneNumber),
            const SizedBox(height: 12),
            _buildInfoRow('Address', _job!.address),
          ],
        ),
      ),
    );
  }

  Widget _buildSalespersonInformation() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Salesperson information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', 'Jane Smith'),
            const SizedBox(height: 12),
            _buildInfoRow('Phone no.', '+123 456-7890'),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteVisitData() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Visit Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Measurements', '15\'*20\''),
            const SizedBox(height: 16),
            Text(
              'Uploaded images',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildImagePlaceholder(),
                const SizedBox(width: 12),
                _buildImagePlaceholder(),
                const SizedBox(width: 12),
                _buildImagePlaceholder(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes about the site visit...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Status',
              _getStatusText(_job!.status),
              valueColor: _getStatusColor(_job!.status),
              valueBackground: _getStatusColor(_job!.status).withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadDraftDesign() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Draft Design',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const UploadDraftWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildComments() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {
    Color? valueColor,
    Color? valueBackground,
  }) {
    final valueWidget = valueBackground != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: valueBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
              ),
            ),
          )
        : Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label -',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: valueWidget),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return 'Approved';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.inProgress:
        return 'In progress';
    }
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.approved:
        return AppTheme.approvedColor;
      case JobStatus.pending:
        return AppTheme.pendingColor;
      case JobStatus.inProgress:
        return AppTheme.inProgressColor;
    }
  }
}