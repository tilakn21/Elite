import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../models/job.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';
import '../widgets/upload_draft_widget.dart';
import '../services/design_service.dart';
import 'chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _messageController = TextEditingController();

  final GlobalKey<UploadDraftWidgetState> _uploadDraftKey = GlobalKey<UploadDraftWidgetState>();
  final _uploadDraftSectionKey = GlobalKey();
  Job? _job;
  Chat? _activeChat;
  bool _isEditingDetails = false;
  bool _showChatPanel = false;
  bool _isRefreshingJobs = false;

  // Status tracking
  double _progressValue = 0.0;
  String _progressStatus = 'Not Started';
  String _estimatedCompletion = 'N/A';
  Map<String, dynamic>? _salespersonEmployeeData;
  bool _isLoadingSalesperson = false;
  
  final DesignService _designService = DesignService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isRefreshingJobs = true);
      await Provider.of<JobProvider>(context, listen: false).fetchJobs();
      setState(() => _isRefreshingJobs = false);
      _loadJobDetails();
      _loadActiveChat();
      await _fetchAssignedSalespersonEmployee();
    });
  }

  @override
  void dispose() {
    setState(() => _isRefreshingJobs = true);
    Provider.of<JobProvider>(context, listen: false).fetchJobs().then((_) {
      setState(() => _isRefreshingJobs = false);
    });
    _notesController.dispose();
    _commentsController.dispose();
    _measurementsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadJobDetails() {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final Job? nullableJob = jobProvider.getJobById(widget.jobId);

    if (nullableJob == null) {
      // Handle the case where job is not found
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job with ID ${widget.jobId} not found.')),
        );
        // Optionally navigate back or show an error UI
        Navigator.of(context).pop();
      }
      return;
    }
    // If we reach here, nullableJob is not null.
    final Job job = nullableJob;

    setState(() {
      _job = job;      _notesController.text = job.notes ?? "";
      _addressController.text = job.address; // job.address is non-nullable
      _phoneController.text = job.phoneNumber; // phoneNumber is non-nullable
      _measurementsController.text = job.measurements ?? "";

      // Set progress based on status
      switch (job.status) {
        case JobStatus.inProgress:
          _progressValue = 0.3;
          _progressStatus = 'In Progress';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().add(const Duration(days: 14)));
          break;
        case JobStatus.pending:
          _progressValue = 0.7;
          _progressStatus = 'Pending Approval';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().add(const Duration(days: 7)));
          break;
        case JobStatus.approved:
          _progressValue = 1.0;
          _progressStatus = 'Completed';
          _estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(DateTime.now().subtract(const Duration(days: 2)));
          break;
      }
    });
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
      final updatedJob = _job!.copyWith(
        status: status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        measurements: _measurementsController.text.isEmpty
            ? null
            : _measurementsController.text,
      );
      setState(() {
        _job = updatedJob;
        // Update progress based on new status
        switch (status) {
          case JobStatus.inProgress:
            _progressValue = 0.3;
            _progressStatus = 'In Progress';
            _estimatedCompletion = DateFormat('dd/MM/yyyy')
                .format(DateTime.now().add(const Duration(days: 14)));
            break;
          case JobStatus.pending:
            _progressValue = 0.7;
            _progressStatus = 'Pending Approval';
            _estimatedCompletion = DateFormat('dd/MM/yyyy')
                .format(DateTime.now().add(const Duration(days: 7)));
            break;
          case JobStatus.approved:
            _progressValue = 1.0;
            _progressStatus = 'Completed';
            _estimatedCompletion =
                DateFormat('dd/MM/yyyy').format(DateTime.now());
            break;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job status updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );    }
  }

  Future<void> _submitForApproval() async {
    if (_job == null) return;

    // Check if comments are empty
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add comments before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if files are selected
    final files = _uploadDraftKey.currentState?.selectedFiles ?? [];
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file to upload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading overlay in UploadDraftWidget
    _uploadDraftKey.currentState?.setLoading(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Submitting designs and comments for approval...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );
    try {
      // Upload images from UploadDraftWidget
      final files = _uploadDraftKey.currentState?.selectedFiles ?? [];
      final List<String> uploadedUrls = [];
      for (final file in files) {
        final url = await DesignService().uploadDraftFile(file);
        if (url != null) uploadedUrls.add(url);
      }
      // Prepare new draft data
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final newDraft = {
        'comments': _commentsController.text,
        'submission_date': dateStr,
        'submission_time': timeStr,
        'status': 'pending_approval',
        'images': uploadedUrls, // Store as List<String>
      };
      // Append new draft to design JSONB (as sub-event)
      await DesignService().updateJobDesignData(_job!.id, newDraft);
      // Update the status column in jobs table to 'design'
      final supabase = Supabase.instance.client;
      await supabase.from('jobs').update({'status': 'design'}).eq('id', _job!.id);
      // Re-fetch the job to update local state with new design JSONB
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.fetchJobs();
      final Job? updatedJob = jobProvider.getJobById(_job!.id);
      setState(() {
        if (updatedJob != null) {
          _job = updatedJob;
        } else {
          _job = _job!.copyWith(status: JobStatus.inProgress);
        }
      });
      _uploadDraftKey.currentState?.clearFiles();
      _commentsController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design submitted for approval successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting design: \\${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _uploadDraftKey.currentState?.setLoading(false);
    }
  }

  void _approveJob() async {
    if (_job == null) return;
    // Find the latest draft with status 'pending_approval' or 'pending for approval'
    final design = _job!.design;
    if (design is List && design.isNotEmpty) {
      for (var i = design.length - 1; i >= 0; i--) {
        final draft = design[i];
        final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
        if (status == 'pending_approval' || status == 'pending for approval') {
          // Update the status to 'completed' for this draft
          final updatedDraft = Map<String, dynamic>.from(draft);
          updatedDraft['status'] = 'completed';
          final updatedDesign = List<Map<String, dynamic>>.from(design);
          updatedDesign[i] = updatedDraft;
          // Update in database
          final supabase = Supabase.instance.client;
          await supabase.from('jobs').update({'design': updatedDesign}).eq('id', _job!.id);
          // Also update locally
          setState(() {
            _job = _job!.copyWith(design: updatedDesign);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design approved and status updated.'), backgroundColor: AppTheme.successColor),
          );
          break;
        }
      }
    }
    // Optionally, update job status as well
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

  void _scrollToUploadDraftSection() {
    final ctx = _uploadDraftSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }  Future<void> _fetchAssignedSalespersonEmployee() async {
    if (_job == null) return;
    
    setState(() { _isLoadingSalesperson = true; });
    
    try {
      // Get the assigned salesperson ID from the receptionist JSONB data
      // The Job.fromJson method already extracts this data properly from the database
      String? assignedSalespersonId;
      
      // First, try to get assignedSalesperson ID from the raw job data
      // by directly querying the database for this specific job
      final supabase = Supabase.instance.client;
      final jobData = await supabase
        .from('jobs')
        .select('receptionist')
        .eq('job_code', _job!.id) // job_code is used as the display ID
        .maybeSingle();
        
      if (jobData != null && jobData['receptionist'] != null) {
        final receptionist = jobData['receptionist'] as Map<String, dynamic>;
        assignedSalespersonId = receptionist['assignedSalesperson']?.toString();
      }
      
      if (assignedSalespersonId == null || assignedSalespersonId.isEmpty) {
        setState(() {
          _salespersonEmployeeData = null;
        });
        return;
      }
      
      // Fetch employee details using the design service pattern
      final employeeData = await _designService.getEmployeeById(assignedSalespersonId);
      
      setState(() {
        _salespersonEmployeeData = employeeData;
      });
    } catch (e) {
      setState(() {
        _salespersonEmployeeData = null;
      });
    } finally {
      setState(() { _isLoadingSalesperson = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isRefreshingJobs) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading job details...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_job == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Job not found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested job could not be loaded.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildModernAppBar(context, isDesktop),
      body: isDesktop
          ? _buildDesktopLayout()
          : isTablet
              ? _buildTabletLayout()
              : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDesktop) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimaryColor,
          tooltip: 'Back to jobs',
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Text(
              'Job #${_job?.id ?? ''}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _job?.clientName ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM yyyy • hh:mm a').format(_job?.dateAdded ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!isDesktop || !_showChatPanel)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline, size: 18),
              ),
              onPressed: _openChatWithCustomer,
              tooltip: 'Chat with customer',
              color: AppTheme.accentColor,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_isEditingDetails ? AppTheme.successColor : AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isEditingDetails ? Icons.save : Icons.edit,
                size: 18,
                color: _isEditingDetails ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
            onPressed: _toggleEditMode,
            tooltip: _isEditingDetails ? 'Save changes' : 'Edit details',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, left: 4),
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert, size: 18),
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Mark as Approved'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_outlined, color: AppTheme.pendingColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Mark as Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'progress',
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Mark as In Progress'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(),
                const SizedBox(height: 28),
                // Site Visit Images section
                _buildSiteVisitImages(),
                const SizedBox(height: 28),
                // Site Visit Data at the top
                _buildSiteVisitData(),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobProgress(),
                          const SizedBox(height: 28),
                          if (_job?.displayStatus != 'Design Completed') ...[
                            _buildUploadDraftDesign(),
                            const SizedBox(height: 28),                            _buildComments(),
                            const SizedBox(height: 28),
                            _buildModernSubmitButton(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Right column: Customer and Salesperson info at the bottom
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerInformation(),
                          const SizedBox(height: 28),
                          _buildSalespersonInformation(),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
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
                                    constraints: const BoxConstraints(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          DateFormat('h:mm a')
                                              .format(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isAdmin
                                                ? Colors.white.withAlpha(179)
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
                          controller: _messageController,
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 24),
          // Site Visit Images section
          _buildSiteVisitImages(),
          const SizedBox(height: 24),
          // Site Visit Data at the top
          _buildSiteVisitData(),
          const SizedBox(height: 24),
          _buildJobProgress(),
          const SizedBox(height: 24),
          if (_job?.displayStatus != 'Design Completed') ...[
            _buildUploadDraftDesign(),
            const SizedBox(height: 24),            _buildComments(),
            const SizedBox(height: 24),
            _buildModernSubmitButton(),
          ],
          const SizedBox(height: 24),
          // Customer and Salesperson info at the bottom
          _buildCustomerInformation(),
          const SizedBox(height: 24),
          _buildSalespersonInformation(),
        ],
      ),
    );
  }
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 20),
          // Site Visit Images section
          _buildSiteVisitImages(),
          const SizedBox(height: 20),
          // Site Visit Data at the top
          _buildSiteVisitData(),
          const SizedBox(height: 20),
          _buildJobProgress(),
          const SizedBox(height: 20),
          if (_job?.displayStatus != 'Design Completed') ...[
            _buildUploadDraftDesign(),
            const SizedBox(height: 20),            _buildComments(),
            const SizedBox(height: 20),
            _buildModernSubmitButton(),
          ],
          const SizedBox(height: 16),
          // Customer and Salesperson info at the bottom
          _buildCustomerInformation(),
          const SizedBox(height: 16),
          _buildSalespersonInformation(),
        ],
      ),
    );
  }
  Widget _buildJobHeader() {
    // Determine display status: if latest draft is pending approval, override
    String displayStatus = _job!.displayStatus;
    Color statusColor = _getStatusColor(_job!.status);
    IconData statusIcon = Icons.pending_outlined;
    
    final design = _job!.design;
    if (design is List && design.isNotEmpty) {
      for (var i = design.length - 1; i >= 0; i--) {
        final draft = design[i];
        final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
        if (status == 'pending_approval' || status == 'pending for approval') {
          displayStatus = 'Pending for Approval';
          statusColor = AppTheme.pendingColor;
          statusIcon = Icons.pending_outlined;
          break;
        } else if (status == 'completed') {
          displayStatus = 'Design Completed';
          statusColor = AppTheme.successColor;
          statusIcon = Icons.check_circle_outline;
          break;
        }
      }
    }

    // Set appropriate icon for status
    switch (_job!.status) {
      case JobStatus.inProgress:
        statusIcon = Icons.play_circle_outline;
        break;
      case JobStatus.approved:
        statusIcon = Icons.check_circle_outline;
        break;
      case JobStatus.pending:
        statusIcon = Icons.pending_outlined;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Details',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created on ${DateFormat('dd MMM yyyy • hh:mm a').format(_job!.dateAdded)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Job info grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildJobInfoItem(
                      'Client',
                      _job!.clientName,
                      Icons.person_outline,
                      AppTheme.primaryColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildJobInfoItem(
                      'Phone',
                      _job!.phoneNumber,
                      Icons.phone_outlined,
                      AppTheme.accentColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildJobInfoItem(
                      'Job Number',
                      _job!.jobNo.isNotEmpty ? _job!.jobNo : _job!.id,
                      Icons.tag,
                      AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    )
    );
  }

  Widget _buildJobInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }  Widget _buildJobProgress() {
    // Compute progress and status based on displayStatus
    double progressValue = 0.0;
    String progressStatus = 'Not Started';
    String estimatedCompletion = 'N/A';
    Color progressColor = AppTheme.textSecondaryColor;
    IconData progressIcon = Icons.schedule_outlined;
    
    if (_job != null) {
      switch (_job!.displayStatus) {
        case 'Queued':
          progressValue = 0.2;
          progressStatus = 'Queued';
          progressColor = AppTheme.pendingColor;
          progressIcon = Icons.queue_outlined;
          estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(_job!.dateAdded.add(const Duration(days: 14)));
          break;
        case 'Pending for Approval':
          progressValue = 0.7;
          progressStatus = 'Pending for Approval';
          progressColor = AppTheme.pendingColor;
          progressIcon = Icons.pending_outlined;
          estimatedCompletion = DateFormat('dd/MM/yyyy')
              .format(_job!.dateAdded.add(const Duration(days: 7)));
          break;
        case 'Design Completed':
          progressValue = 1.0;
          progressStatus = 'Design Completed';
          progressColor = AppTheme.successColor;
          progressIcon = Icons.check_circle_outline;
          estimatedCompletion = DateFormat('dd/MM/yyyy').format(DateTime.now());
          break;
        default:
          progressValue = 0.0;
          progressStatus = _job!.displayStatus;
          progressColor = AppTheme.inProgressColor;
          progressIcon = Icons.work_outline;
          estimatedCompletion = 'N/A';
      }
    }

    // --- MODIFICATION: Display job_code (job number) in progress info grid ---
    final String jobNumber = _job?.id ?? '-'; // _job!.id is set to job_code in Job.fromJson

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            progressColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: progressColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(progressIcon, color: progressColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  progressStatus,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Enhanced progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: progressColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Progress info grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: progressColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Job Number
                  _buildProgressItem('Job Number', jobNumber, Icons.confirmation_number_outlined, progressColor),
                  _buildProgressItem('Estimated Completion', estimatedCompletion, Icons.event_available, progressColor),
                  _buildProgressItem('Progress', '${(progressValue * 100).toInt()}%', Icons.trending_up, progressColor),
                ],
              ),
            ),
          ],
        ),
      ),
    ); // <-- Add missing closing parenthesis for Container
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }  Widget _buildCustomerInformation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Customer Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.successColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildModernInfoRow(
                    'Client Name',
                    _job!.clientName,
                    Icons.person_outline,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInfoRow(
                    'Phone Number',
                    _job!.phoneNumber,
                    Icons.phone_outlined,
                    AppTheme.accentColor,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInfoRow(
                    'Address',
                    _job!.address,
                    Icons.location_on_outlined,
                    AppTheme.textSecondaryColor,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
    ));
  }

  Widget _buildSalespersonInformation() {
    // Use _salespersonEmployeeData if available, else fallback to old UI
    if (_isLoadingSalesperson) {
      return Center(child: CircularProgressIndicator());
    }
    if (_salespersonEmployeeData == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Text('No assigned salesperson found.'),
      );
    }
    final emp = _salespersonEmployeeData!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.accentColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_center_outlined,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Assigned Salesperson',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildModernInfoRow(
                    'Name',
                    emp['full_name'] ?? '-',
                    Icons.person_outline,
                    AppTheme.accentColor,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInfoRow(
                    'Phone Number',
                    emp['phone'] ?? '-',
                    Icons.phone_outlined,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInfoRow(
                    'Department',
                    emp['role'] ?? '-',
                    Icons.work_outline,
                    AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
    )
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon, Color color, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }Widget _buildSiteVisitData() {
    final Map<String, dynamic> salespersonData = _job?.salespersonData ?? {};

    // Helper to get a value or fallback
    String getField(String key, [String fallback = '-']) {
      final value = salespersonData[key];
      if (value == null || (value is String && value.trim().isEmpty)) return fallback;
      return value.toString();
    }

    // Fields to exclude
    const excludedFields = {'customer', 'paymentAmount', 'salespersonId', 'imageUrl', 'images'};

    // Build info rows for all fields except excluded and image URLs
    final infoRows = <Widget>[];
    
    // Sort keys alphabetically for better organization
    final sortedKeys = salespersonData.keys.where((key) => 
      !excludedFields.contains(key) && 
      !(salespersonData[key] is String && 
        (salespersonData[key] as String).startsWith('http') && 
        RegExp(r'\.(jpg|jpeg|png|webp|gif)$', caseSensitive: false).hasMatch(salespersonData[key]))
    ).toList()..sort();
    
    // Process sorted keys
    for (var key in sortedKeys) {
      var value = salespersonData[key];
      
      // Handle date and time separation
      if (key.toLowerCase().contains('date') && value is String && value.contains(' ') && value.length > 10) {
        // This could be a datetime string, try to split it
        try {
          final parts = value.split(' ');
          if (parts.length >= 2) {
            final dateStr = parts[0];
            final timeStr = parts.sublist(1).join(' ');
              infoRows.add(_buildInfoRow(
              context,
              '${_beautifyKey(key)} (Date)', 
              dateStr,
              icon: Icons.calendar_today_outlined,
            ));
            infoRows.add(const SizedBox(height: 12));
            infoRows.add(_buildInfoRow(
              context,
              '${_beautifyKey(key)} (Time)', 
              timeStr,
              icon: Icons.access_time,
            ));
            infoRows.add(const Divider(height: 24));          } else {
            infoRows.add(_buildInfoRow(context, _beautifyKey(key), getField(key)));
            infoRows.add(const Divider(height: 24));
          }
        } catch (e) {
          // If parsing fails, just display as is
          infoRows.add(_buildInfoRow(context, _beautifyKey(key), getField(key)));
          infoRows.add(const Divider(height: 24));
        }
      } else {
        // Add appropriate icons based on field type
        IconData? fieldIcon;
        if (key.toLowerCase().contains('name')) {
          fieldIcon = Icons.person_outline;
        } else if (key.toLowerCase().contains('phone') || key.toLowerCase().contains('contact')) {
          fieldIcon = Icons.phone_outlined;
        } else if (key.toLowerCase().contains('email')) {
          fieldIcon = Icons.email_outlined;
        } else if (key.toLowerCase().contains('address')) {
          fieldIcon = Icons.location_on_outlined;
        } else if (key.toLowerCase().contains('note') || key.toLowerCase().contains('comment')) {
          fieldIcon = Icons.description_outlined;
        } else if (key.toLowerCase().contains('price') || key.toLowerCase().contains('cost') || key.toLowerCase().contains('amount')) {
          fieldIcon = Icons.attach_money;
        }        
        infoRows.add(_buildInfoRow(context, _beautifyKey(key), getField(key), icon: fieldIcon));
        // Use divider instead of simple spacing for better visual separation
        if (sortedKeys.last != key) {
          infoRows.add(const Divider(height: 24));
        }
      }
    }

    if (infoRows.isEmpty) {
      infoRows.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No site visit data available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        )
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text('Site Visit Data', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ],
            ),
            const SizedBox(height: 24),
            ...infoRows,
          ],
        ),
      ),
    );
  }  Widget _buildSiteVisitImages() {
    // If job is in queued or has a draft pending approval/completed, show appropriate UI
    if (_job != null) {
      final design = _job!.design;
      Map<String, dynamic>? latestDraft;
      String? latestStatus;
      if (design is List && design.isNotEmpty) {
        for (var i = design.length - 1; i >= 0; i--) {
          final draft = design[i];
          final status = draft is Map<String, dynamic> ? draft['status']?.toString().toLowerCase() : null;
          if (status == 'pending_approval' || status == 'pending for approval' || status == 'completed') {
            latestDraft = Map<String, dynamic>.from(draft);
            latestStatus = status;
            break;
          }
        }
      }
      // If latest draft is pending approval, show draft with approve/upload buttons
      if (latestDraft != null && (latestStatus == 'pending_approval' || latestStatus == 'pending for approval')) {
        final List images = latestDraft['images'] ?? [];
        final String comment = latestDraft['comments'] ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.yellow[50],
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Design Draft Pending Approval', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (images.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: images.map<Widget>((imgUrl) => GestureDetector(
                          onTap: () => _showImageDialog(imgUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imgUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Comment:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(comment, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _approveJob,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Approve Design'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _scrollToUploadDraftSection,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Another Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildSiteVisitImagesCard(),
          ],
        );
      }
      // If latest draft is completed, show completed UI
      if (latestDraft != null && latestStatus == 'completed') {
        final List images = latestDraft['images'] ?? [];
        final String comment = latestDraft['comments'] ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[50],
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Design Completed', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (images.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: images.map<Widget>((imgUrl) => GestureDetector(
                          onTap: () => _showImageDialog(imgUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imgUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Comment:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(comment, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            _buildSiteVisitImagesCard(),
          ],
        );
      }
    }
    // If job is queued or no draft, show upload draft UI only
    return _buildSiteVisitImagesCard();
  }

  Widget _buildSiteVisitImagesCard() {
    final Map<String, dynamic> salespersonData = _job?.salespersonData ?? {};
    final List<String> imageUrls = [];
    // Check if there's an images array in the salesperson data
    if (salespersonData.containsKey('images') && salespersonData['images'] != null) {
      // Handle images as an array
      if (salespersonData['images'] is List) {
        for (var imageUrl in salespersonData['images']) {
          if (imageUrl is String && imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
          }
        }
      } 
      // Handle images as a comma-separated string (used by UploadDraftWidget)
      else if (salespersonData['images'] is String && salespersonData['images'].isNotEmpty) {
        if (salespersonData['images'].contains(',')) {
          // Split the comma-separated string into individual URLs
          final urlsList = salespersonData['images'].split(',');
          for (var url in urlsList) {
            if (url.trim().isNotEmpty) {
              imageUrls.add(url.trim());
            }
          }
        } else {
          // It's a single URL string
          imageUrls.add(salespersonData['images']);
        }
      }
    }
    // Also look for any other image URLs in other fields as a fallback
    salespersonData.forEach((key, value) {
      if (key != 'images' && value is String && 
          (value.startsWith('https://') || value.startsWith('http://')) && 
          RegExp(r'\.(jpg|jpeg|png|webp|gif)', caseSensitive: false).hasMatch(value)) {
        imageUrls.add(value);
      }
    });
    // If no images are found, show a "No site images" message
    if (imageUrls.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('No site visit images available', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Site Visit Images', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: imageUrls.map((url) => GestureDetector(
                onTap: () => _showImageDialog(url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),    );
  }

  Widget _buildUploadDraftDesign() {
    return Container(
      key: _uploadDraftSectionKey,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3F2FD),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF1976D2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.upload_file_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Upload Draft Design',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: UploadDraftWidget(
                  key: _uploadDraftKey,
                  jobId: widget.jobId,
                  comments: _commentsController.text,
                ),
              ),
            ),
          ],
        ),      ),
    );
  }

  Widget _buildComments() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3F2FD),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF1976D2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.comment_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _commentsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add your comments here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    Color? valueBackground,
    IconData? icon,
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                ),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  '$label -',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: valueWidget),
      ],
    );
  }
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
          ),
        ),
    ));
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
  String _beautifyKey(String key) {
    // Convert camelCase or snake_case to Title Case for labels
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ' + m.group(0)!)
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }

  Widget _buildModernSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitForApproval,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Submit for Approval',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
    ));
  }
}
